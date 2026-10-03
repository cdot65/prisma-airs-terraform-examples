# Optional resources share the application's state and destroy workflow.
resource "prisma-airs_gateway_secret_reference" "upstream" {
  count                = var.secret_manager == null ? 0 : 1
  name                 = "${var.name_prefix}-upstream-secret"
  manager_type         = var.secret_manager.manager_type
  secret_path          = var.secret_manager.secret_path
  secret_key           = var.secret_manager.secret_key
  auth_config          = var.secret_manager_auth
  allow_all_workspaces = false
  allowed_workspaces   = [var.workspace_id]
}
resource "prisma-airs_gateway_user_api_key" "developer" {
  count        = var.developer_user_id == null ? 0 : 1
  name         = "${var.name_prefix}-developer-key"
  workspace_id = var.workspace_id
  user_id      = var.developer_user_id
  scopes       = ["completions.write"]
  defaults = {
    config_id             = prisma-airs_gateway_config.routing["fallback"].id
    allow_config_override = false
    metadata              = { application = var.name_prefix }
  }
}
resource "prisma-airs_gateway_mcp_integration" "tools" {
  count          = var.enable_mcp ? 1 : 0
  name           = "${var.name_prefix}-mcp-integration"
  url            = var.mcp_url
  auth_type      = var.mcp_auth_type
  transport      = "http"
  configurations = var.mcp_configurations
}
resource "prisma-airs_gateway_mcp_integration_workspace_binding" "tools" {
  count          = var.enable_mcp ? 1 : 0
  integration_id = prisma-airs_gateway_mcp_integration.tools[0].id
  workspace_id   = var.workspace_id
}
resource "prisma-airs_gateway_mcp_server" "tools" {
  count              = var.enable_mcp ? 1 : 0
  name               = "${var.name_prefix}-mcp-server"
  workspace_id       = var.workspace_id
  mcp_integration_id = prisma-airs_gateway_mcp_integration.tools[0].id
  depends_on         = [prisma-airs_gateway_mcp_integration_workspace_binding.tools]
}
resource "prisma-airs_gateway_deployment" "hybrid" {
  count             = var.enable_deployment_registration ? 1 : 0
  name              = "${var.name_prefix}-hybrid-registration"
  type              = "non_production"
  is_default        = false
  deployment_config = var.deployment_config
  auth_settings     = var.deployment_auth_settings
}
# This policy applies across ALL workspaces; explicit opt-in only.
resource "prisma-airs_gateway_org_guardrail" "baseline" {
  count  = var.enable_org_guardrail ? 1 : 0
  name   = "${var.name_prefix}-organization-baseline"
  checks = [{ id = "default.contains", is_enabled = true }]
  check_parameters = {
    "default.contains" = { operator = "none", words = ["${var.name_prefix}_ORG_BLOCK"] }
  }
  actions = local.deny_actions
}
