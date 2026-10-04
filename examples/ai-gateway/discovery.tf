# Inventory: Refresh pages after owned writes so summary counts reflect the apply.
data "prisma-airs_gateway_configs" "catalog" {
  depends_on   = [prisma-airs_gateway_config.routing]
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_guardrails" "catalog" {
  depends_on   = [prisma-airs_gateway_guardrail.marker, prisma-airs_gateway_guardrail.airs]
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_org_guardrails" "catalog" {
  depends_on = [prisma-airs_gateway_org_guardrail.baseline]
  count      = var.enable_platform_discovery ? 1 : 0
}

data "prisma-airs_gateway_integrations" "catalog" {
  depends_on = [prisma-airs_gateway_integration.models]
  count      = var.enable_platform_discovery ? 1 : 0
}

data "prisma-airs_gateway_providers" "catalog" {
  depends_on   = [prisma-airs_gateway_provider.models]
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_mcp_integrations" "catalog" {
  depends_on = [prisma-airs_gateway_mcp_integration.tools]
  count      = var.enable_platform_discovery ? 1 : 0
}

data "prisma-airs_gateway_mcp_servers" "catalog" {
  depends_on   = [prisma-airs_gateway_mcp_server.tools]
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_service_api_keys" "catalog" {
  depends_on   = [prisma-airs_gateway_service_api_key.application]
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_user_api_keys" "catalog" {
  depends_on   = [prisma-airs_gateway_user_api_key.developer]
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_usage_limits" "catalog" {
  depends_on   = [prisma-airs_gateway_usage_limit.application]
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_rate_limits" "catalog" {
  depends_on   = [prisma-airs_gateway_rate_limit.application]
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_secret_references" "catalog" {
  depends_on = [prisma-airs_gateway_secret_reference.upstream]
  count      = var.enable_platform_discovery ? 1 : 0
}

data "prisma-airs_gateway_deployments" "catalog" {
  depends_on = [prisma-airs_gateway_deployment.hybrid]
  count      = var.enable_platform_discovery ? 1 : 0
}


# Summary: Show returned page sizes, not inferred tenant-wide totals.
output "platform_page_counts" {
  description = "Returned item counts per discovery page; null when disabled. These are not complete inventories."
  value = var.enable_platform_discovery ? {
    configs           = length(data.prisma-airs_gateway_configs.catalog[0].items)
    guardrails        = length(data.prisma-airs_gateway_guardrails.catalog[0].items)
    org_guardrails    = length(data.prisma-airs_gateway_org_guardrails.catalog[0].items)
    integrations      = length(data.prisma-airs_gateway_integrations.catalog[0].items)
    providers         = length(data.prisma-airs_gateway_providers.catalog[0].items)
    mcp_integrations  = length(data.prisma-airs_gateway_mcp_integrations.catalog[0].items)
    mcp_servers       = length(data.prisma-airs_gateway_mcp_servers.catalog[0].items)
    service_api_keys  = length(data.prisma-airs_gateway_service_api_keys.catalog[0].items)
    user_api_keys     = length(data.prisma-airs_gateway_user_api_keys.catalog[0].items)
    usage_limits      = length(data.prisma-airs_gateway_usage_limits.catalog[0].items)
    rate_limits       = length(data.prisma-airs_gateway_rate_limits.catalog[0].items)
    secret_references = length(data.prisma-airs_gateway_secret_references.catalog[0].items)
    deployments       = length(data.prisma-airs_gateway_deployments.catalog[0].items)
  } : null
}
