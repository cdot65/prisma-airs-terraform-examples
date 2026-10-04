# Setup: Use the provider release that adds adapter ownership and discovery.
terraform {
  required_version = ">= 1.11.0, < 2.0.0"
  required_providers {
    prisma-airs = {
      source  = "cdot65/prisma-airs"
      version = "= 0.12.0"
    }
  }
}

# Authentication: Load management OAuth credentials from PANW_MGMT_*.
provider "prisma-airs" {}

# Adapter: Save a draft first; activation explicitly executes this script.
resource "prisma-airs_red_team_adapter" "example" {
  name                        = "${var.name_prefix}-adapter"
  description                 = "Text-only adapter connectivity exercise."
  script                      = file("${path.module}/adapter.py")
  network_broker_channel_uuid = var.network_broker_channel_uuid
  variables                   = var.adapter_variables
  validate                    = var.activate
  validation_prompt           = "Text-only Terraform connectivity exercise"
}

# Target: Register the adapter contract after its explicit activation succeeds.
resource "prisma-airs_red_team_target" "example" {
  count                       = var.activate ? 1 : 0
  name                        = "${var.name_prefix}-target"
  target_type                 = "APPLICATION"
  api_endpoint_type           = "NETWORK_BROKER"
  network_broker_channel_uuid = var.network_broker_channel_uuid

  adapter {
    uuid = prisma-airs_red_team_adapter.example.id
  }
}

# Discovery: Look up tenant-visible identities without taking additional ownership.
data "prisma-airs_red_team_adapters" "available" {
  depends_on = [prisma-airs_red_team_adapter.example]
}

data "prisma-airs_red_team_adapter" "example" {
  id = data.prisma-airs_red_team_adapters.available.ids_by_name["${var.name_prefix}-adapter"]
}
