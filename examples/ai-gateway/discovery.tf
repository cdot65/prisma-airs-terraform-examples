# Inventory: Opt in to metadata reads for every released Gateway family.
data "prisma-airs_gateway_configs" "catalog" {
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_guardrails" "catalog" {
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_org_guardrails" "catalog" {
  count = var.enable_platform_discovery ? 1 : 0
}

data "prisma-airs_gateway_integrations" "catalog" {
  count = var.enable_platform_discovery ? 1 : 0
}

data "prisma-airs_gateway_providers" "catalog" {
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_mcp_integrations" "catalog" {
  count = var.enable_platform_discovery ? 1 : 0
}

data "prisma-airs_gateway_mcp_servers" "catalog" {
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_service_api_keys" "catalog" {
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_user_api_keys" "catalog" {
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_usage_limits" "catalog" {
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_rate_limits" "catalog" {
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_secret_references" "catalog" {
  count = var.enable_platform_discovery ? 1 : 0
}

data "prisma-airs_gateway_deployments" "catalog" {
  count = var.enable_platform_discovery ? 1 : 0
}

