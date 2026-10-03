# Setup: Pin the provider and Terraform versions used by this example.
terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    prisma-airs = {
      source  = "cdot65/prisma-airs"
      version = "= 0.9.0"
    }
  }
}

# Authentication: Read management credentials from PANW_MGMT_* environment variables.
provider "prisma-airs" {}

# Connections: Create one owned integration for each named upstream.
resource "prisma-airs_gateway_integration" "models" {
  for_each       = var.upstreams
  name           = "${var.name_prefix}-${each.key}-integration"
  description    = "Owned application connection (${var.description_suffix})."
  ai_provider_id = each.value.ai_provider_id
  key            = each.key == var.secret_for_upstream ? null : var.upstream_api_keys[each.key]
  configurations = lookup(var.upstream_configurations, each.key, {})

  secret_mappings = each.key == var.secret_for_upstream ? [
    {
      target_field        = "key"
      secret_reference_id = prisma-airs_gateway_secret_reference.upstream[0].id
    },
  ] : []
}

# Workspace access: Bind integrations before exposing them as workspace providers.
resource "prisma-airs_gateway_integration_workspace_binding" "models" {
  for_each       = var.upstreams
  integration_id = prisma-airs_gateway_integration.models[each.key].id
  workspace_id   = var.workspace_id
}

resource "prisma-airs_gateway_provider" "models" {
  for_each       = var.upstreams
  name           = "${var.name_prefix}-${each.key}-provider"
  integration_id = prisma-airs_gateway_integration.models[each.key].id
  workspace_id   = var.workspace_id

  depends_on = [prisma-airs_gateway_integration_workspace_binding.models]
}

# Inspection: Own the profile; the existing tenant AIRS plugin supplies scanning access.
resource "prisma-airs_runtime_security_profile" "gateway" {
  profile_name = "${var.name_prefix}-gateway-policy"

  ai_security_profile {
    model_type = "default"

    model_protection {
      name   = "prompt-injection"
      action = "block"
    }
  }
}

# Guardrails: Share synchronous denial actions between marker and AIRS checks.
locals {
  deny_actions = {
    deny  = true
    async = false

    on_success = {
      feedback = {
        value    = 1
        weight   = 1
        metadata = ""
      }
    }

    on_fail = {
      feedback = {
        value    = -1
        weight   = 1
        metadata = ""
      }
    }
  }
}

resource "prisma-airs_gateway_guardrail" "marker" {
  name         = "${var.name_prefix}-deny-marker"
  workspace_id = var.workspace_id

  checks = [
    {
      id         = "default.contains"
      is_enabled = true
    },
  ]

  check_parameters = {
    "default.contains" = {
      operator = "none"
      words    = ["AIRS_DEMO_BLOCK"]
    }
  }

  actions = local.deny_actions
}

resource "prisma-airs_gateway_guardrail" "airs" {
  name         = "${var.name_prefix}-airs-inspection"
  workspace_id = var.workspace_id

  checks = [
    {
      id         = "panw-prisma-airs.intercept"
      is_enabled = true
    },
  ]

  check_parameters = {
    "panw-prisma-airs.intercept" = {
      profile_name = prisma-airs_runtime_security_profile.gateway.profile_name
    }
  }

  actions = local.deny_actions
}

# Routing: Attach the same request checks to all four lessons from routing.tf.
resource "prisma-airs_gateway_config" "routing" {
  for_each     = local.routing_configs
  name         = "${var.name_prefix}-${each.key}"
  workspace_id = var.workspace_id

  config = merge(each.value, {
    before_request_hooks = concat(
      [
        { id = prisma-airs_gateway_guardrail.marker.slug },
        { id = prisma-airs_gateway_guardrail.airs.slug },
      ],
      var.enable_org_guardrail ? [{ id = prisma-airs_gateway_org_guardrail.baseline[0].slug }] : [],
    )
  })
}

# Application access: Each key selects a saved config and disables config overrides.
resource "prisma-airs_gateway_service_api_key" "application" {
  for_each     = local.routing_configs
  name         = "${var.name_prefix}-${each.key}-key"
  workspace_id = var.workspace_id
  scopes       = var.enable_mcp ? ["completions.write", "mcp.invoke"] : ["completions.write"]

  defaults = {
    config_id             = prisma-airs_gateway_config.routing[each.key].id
    allow_config_override = false

    metadata = {
      application = var.name_prefix
    }
  }
}

# Limits: Aggregate requests and tokens across keys carrying this application metadata.
resource "prisma-airs_gateway_rate_limit" "application" {
  name         = "${var.name_prefix}-request-limit"
  workspace_id = var.workspace_id
  type         = "requests"
  unit         = "rpm"
  target       = "llm"
  value        = var.requests_per_minute

  conditions = [
    {
      key   = "metadata.application"
      value = var.name_prefix
    },
  ]

  group_by = [
    {
      key = "metadata.application"
    },
  ]
}

resource "prisma-airs_gateway_usage_limit" "application" {
  name            = "${var.name_prefix}-token-budget"
  workspace_id    = var.workspace_id
  type            = "tokens"
  credit_limit    = var.token_budget
  alert_threshold = max(1, floor(var.token_budget * 0.2))
  periodic_reset  = "monthly"

  conditions = [
    {
      key   = "metadata.application"
      value = var.name_prefix
    },
  ]

  group_by = [
    {
      key = "metadata.application"
    },
  ]
}
