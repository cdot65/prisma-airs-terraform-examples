# Workspace: Opt in to a new workspace; existing-workspace users keep their state addresses.
resource "prisma-airs_gateway_workspace" "application" {
  count            = var.create_workspace ? 1 : 0
  name             = "${var.name_prefix}-workspace"
  description      = "Owned application workspace (${var.description_suffix})."
  scope_name       = var.workspace_scope_name
  scope_management = var.workspace_scope_management

  defaults = {
    metadata = var.workspace_default_metadata
  }

  rate_limits = var.workspace_rate_limits
}

# Dependency: Every child uses the selected UUID; destroy children before their workspace.
locals {
  workspace_id = var.create_workspace ? prisma-airs_gateway_workspace.application[0].id : var.workspace_id
}

# Discovery: Read safe workspace metadata; list completeness is reported, not assumed.
data "prisma-airs_gateway_workspace" "selected" {
  count        = var.enable_platform_discovery ? 1 : 0
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_workspaces" "active" {
  depends_on = [prisma-airs_gateway_workspace.application]
  count      = var.enable_platform_discovery ? 1 : 0
  status     = "active"
}

output "workspace" {
  value = {
    id                 = local.workspace_id
    slug               = var.enable_platform_discovery ? data.prisma-airs_gateway_workspace.selected[0].slug : (var.create_workspace ? prisma-airs_gateway_workspace.application[0].slug : null)
    owned              = var.create_workspace
    inventory_complete = var.enable_platform_discovery ? data.prisma-airs_gateway_workspaces.active[0].complete : null
  }
}
