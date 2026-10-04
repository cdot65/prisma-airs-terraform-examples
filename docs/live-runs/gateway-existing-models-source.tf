terraform {
  required_providers {
    prisma-airs = { source = "cdot65/prisma-airs" }
  }
}
provider "prisma-airs" {}
variable "workspace_id" { type = string }
variable "routes" { type = map(object({ provider_slug = string, model = string })) }
data "prisma-airs_gateway_providers" "existing" { workspace_id = var.workspace_id }
locals { providers = { for p in data.prisma-airs_gateway_providers.existing.items : p.slug => p } }
resource "prisma-airs_gateway_config" "probe" {
  for_each     = var.routes
  name         = "tf-recorded-model-${each.key}"
  workspace_id = var.workspace_id
  config = {
    provider        = "@${local.providers[each.value.provider_slug].slug}"
    override_params = { model = each.value.model }
    retry           = { attempts = 0 }
  }
}
resource "prisma-airs_gateway_service_api_key" "probe" {
  for_each     = var.routes
  name         = "tf-recorded-model-${each.key}"
  workspace_id = var.workspace_id
  scopes       = ["completions.write"]
  defaults = {
    config_id             = prisma-airs_gateway_config.probe[each.key].id
    allow_config_override = false
    metadata              = { application = "tf-recorded-model" }
  }
}
output "keys" {
  value     = { for label, key in prisma-airs_gateway_service_api_key.probe : label => key.key }
  sensitive = true
}
output "routes" { value = var.routes }
