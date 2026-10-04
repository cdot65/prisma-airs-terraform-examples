# Setup: Use the catalog-capable development provider until its release.
terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    prisma-airs = {
      source  = "cdot65/prisma-airs"
      version = "> 0.10.0, < 1.0.0"
    }
  }
}

# Authentication: Discovery needs management credentials, not upstream API keys.
provider "prisma-airs" {}

# Discovery: Read catalog entries without owning upstream connections.
data "prisma-airs_gateway_ai_providers" "catalog" {}

# Lookup: Select the UUIDs by the exact catalog slugs used for integration creation.
output "provider_family_ids" {
  value = {
    open-ai   = data.prisma-airs_gateway_ai_providers.catalog.ids_by_slug["open-ai"]
    anthropic = data.prisma-airs_gateway_ai_providers.catalog.ids_by_slug["anthropic"]
  }
}

output "catalog_counts" {
  value = {
    returned = length(data.prisma-airs_gateway_ai_providers.catalog.items)
    active   = length(data.prisma-airs_gateway_ai_providers.catalog.ids_by_slug)
  }
}
