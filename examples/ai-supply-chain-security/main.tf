# Setup: Pin the provider and Terraform versions used by this example.
terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    prisma-airs = {
      source  = "cdot65/prisma-airs"
      version = "= 0.10.0"
    }
  }
}

# Authentication: Read management credentials from PANW_MGMT_* environment variables.
provider "prisma-airs" {}

# Discovery: Read the available rules without changing shared policy.
data "prisma-airs_supply_chain_security_rules" "catalog" {}

# Group: Create a Hugging Face model container; onboarding and scans are separate.
resource "prisma-airs_supply_chain_security_group" "models" {
  name        = "${var.name_prefix}-model-security"
  description = "Hugging Face model security group (${var.description_suffix})."
  source_type = "HUGGING_FACE"
}

# Outputs: Use the group ID and rule catalog in the model onboarding workflow.
output "group_id" {
  value = prisma-airs_supply_chain_security_group.models.uuid
}

output "rule_count" {
  value = length(data.prisma-airs_supply_chain_security_rules.catalog.rules)
}

output "rule_names" {
  value = [for rule in data.prisma-airs_supply_chain_security_rules.catalog.rules : rule.name]
}
