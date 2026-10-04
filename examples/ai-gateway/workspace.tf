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
  workspace_id = local.workspace_id
}

data "prisma-airs_gateway_workspaces" "active" {
  status = "active"
}

output "workspace" {
  value = {
    id                 = data.prisma-airs_gateway_workspace.selected.id
    slug               = data.prisma-airs_gateway_workspace.selected.slug
    owned              = var.create_workspace
    inventory_complete = data.prisma-airs_gateway_workspaces.active.complete
  }
}
