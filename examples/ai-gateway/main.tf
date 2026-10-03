terraform {
  required_version = ">= 1.8.0, < 2.0.0"
  required_providers {
    prisma-airs = {
      source  = "cdot65/prisma-airs"
      version = "= 0.9.0"
    }
  }
}

provider "prisma-airs" {}

data "prisma-airs_gateway_providers" "workspace" {
  workspace_id = var.workspace_id
  page_size    = 100
  current_page = 1
}

resource "prisma-airs_gateway_config" "application" {
  name         = "${var.name_prefix}-application-routing"
  workspace_id = var.workspace_id
  config = {
    targets = [{
      provider        = "@${var.provider_slug}"
      override_params = { model = var.model }
    }]
    retry = { attempts = var.retry_attempts }
  }
}

resource "prisma-airs_gateway_rate_limit" "application" {
  name         = "${var.name_prefix}-application-rate-limit"
  workspace_id = var.workspace_id
  type         = "requests"
  unit         = "rpm"
  target       = "llm"
  value        = var.requests_per_minute
  conditions   = [{ key = "metadata.application", value = var.name_prefix }]
  group_by     = [{ key = "metadata.application" }]
}

output "config_id" {
  value = prisma-airs_gateway_config.application.id
}

output "config_version_id" {
  value = prisma-airs_gateway_config.application.version_id
}

output "rate_limit_id" {
  value = prisma-airs_gateway_rate_limit.application.id
}

output "provider_count_on_first_page" {
  value = length(data.prisma-airs_gateway_providers.workspace.items)
}
