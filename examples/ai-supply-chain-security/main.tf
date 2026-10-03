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

data "prisma-airs_supply_chain_security_rules" "catalog" {}

resource "prisma-airs_supply_chain_security_group" "models" {
  name        = "${var.name_prefix}-model-security"
  description = "Hugging Face model security group (${var.description_suffix})."
  source_type = "HUGGING_FACE"
}

output "group_id" {
  value = prisma-airs_supply_chain_security_group.models.uuid
}

output "rule_count" {
  value = length(data.prisma-airs_supply_chain_security_rules.catalog.rules)
}

output "rule_names" {
  value = [for rule in data.prisma-airs_supply_chain_security_rules.catalog.rules : rule.name]
}
