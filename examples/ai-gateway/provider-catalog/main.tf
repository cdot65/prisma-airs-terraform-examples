# Setup: Use the catalog-capable provider build until its Registry release.
terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    prisma-airs = {
      source  = "cdot65/prisma-airs"
      version = "> 0.10.0, < 1.0.0"
    }
  }
}

# Authentication: Load management credentials through PANW_MGMT_*.
provider "prisma-airs" {}

variable "workspace_id" {
  description = "Existing Gateway workspace UUID; this project does not own it."
  type        = string
}

variable "name_prefix" {
  description = "Unused prefix for this project's owned connections and routes."
  type        = string
  default     = "tf-catalog-chat"
}

variable "upstream_api_keys" {
  description = "Upstream API credentials keyed by open-ai and anthropic; load from the environment."
  type        = map(string)
  sensitive   = true

  validation {
    condition = alltrue([
      for slug in ["open-ai", "anthropic"] :
      try(length(trimspace(var.upstream_api_keys[slug])) > 0, false)
    ])
    error_message = "Supply both open-ai and anthropic API credentials through TF_VAR_upstream_api_keys."
  }
}

variable "models" {
  description = "API model IDs enabled in Gateway and available to each upstream account."
  type        = map(string)
  default = {
    open-ai   = "gpt-4.1"
    anthropic = "claude-opus-4-6"
  }

  validation {
    condition = toset(keys(var.models)) == toset(["open-ai", "anthropic"]) && alltrue([
      for model in values(var.models) : length(trimspace(model)) > 0
    ])
    error_message = "Set exactly open-ai and anthropic, each with a nonempty API model ID."
  }
}

# Discovery: Resolve active provider-family UUIDs by exact catalog slug.
data "prisma-airs_gateway_ai_providers" "catalog" {}

# Connections: Terraform owns these integrations, not the catalog entries.
resource "prisma-airs_gateway_integration" "chat" {
  for_each       = var.models
  name           = "${var.name_prefix}-${each.key}"
  ai_provider_id = data.prisma-airs_gateway_ai_providers.catalog.ids_by_slug[each.key]
  key            = var.upstream_api_keys[each.key]
}

# Workspace access: Authorize the existing workspace before creating providers.
resource "prisma-airs_gateway_integration_workspace_binding" "chat" {
  for_each       = var.models
  integration_id = prisma-airs_gateway_integration.chat[each.key].id
  workspace_id   = var.workspace_id
}

resource "prisma-airs_gateway_provider" "chat" {
  for_each       = var.models
  name           = "${var.name_prefix}-${each.key}"
  integration_id = prisma-airs_gateway_integration.chat[each.key].id
  workspace_id   = var.workspace_id
  depends_on     = [prisma-airs_gateway_integration_workspace_binding.chat]
}

# Routing: Model IDs select GPT or Claude within their respective connections.
resource "prisma-airs_gateway_config" "chat" {
  for_each     = var.models
  name         = "${var.name_prefix}-${each.key}"
  workspace_id = var.workspace_id

  config = {
    provider = "@${prisma-airs_gateway_provider.chat[each.key].slug}"

    override_params = {
      model = each.value
    }

    retry = {
      attempts = 1
    }
  }
}

# Application access: Give each model route its own scoped credential.
resource "prisma-airs_gateway_service_api_key" "chat" {
  for_each     = var.models
  name         = "${var.name_prefix}-${each.key}"
  workspace_id = var.workspace_id
  scopes       = ["completions.write"]

  defaults = {
    config_id             = prisma-airs_gateway_config.chat[each.key].id
    allow_config_override = false
  }
}

# Outputs: Return UUIDs and selected models without exposing upstream keys.
output "routes" {
  value = {
    for slug, model in var.models : slug => {
      ai_provider_id = data.prisma-airs_gateway_ai_providers.catalog.ids_by_slug[slug]
      integration_id = prisma-airs_gateway_integration.chat[slug].id
      provider_id    = prisma-airs_gateway_provider.chat[slug].id
      config_id      = prisma-airs_gateway_config.chat[slug].id
      model          = model
    }
  }
}

output "application_keys" {
  description = "Sensitive Gateway keys; protect state and saved plans."
  sensitive   = true
  value       = { for slug, key in prisma-airs_gateway_service_api_key.chat : slug => key.key }
}
