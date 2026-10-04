# Catalog: Read published rules and the tenant's effective policy without changing it.
data "prisma-airs_supply_chain_skill_scanning_rules" "catalog" {
  count = var.enable_skill_scanning ? 1 : 0
}

data "prisma-airs_supply_chain_skill_scanning_rule_instances" "effective" {
  count = var.enable_skill_scanning ? 1 : 0
}

# Trust: Use a synthetic fingerprint for the lesson; reason changes replace the override.
resource "prisma-airs_supply_chain_skill_scanning_override" "example" {
  count       = var.enable_skill_scanning ? 1 : 0
  skill_name  = "${var.name_prefix}-synthetic-skill"
  fingerprint = sha256("terraform-disposable-example:${var.name_prefix}")
  trusted_by  = "terraform-example@example.com"
  reason      = "Synthetic fingerprint for the example (${var.description_suffix})."
}

data "prisma-airs_supply_chain_skill_scanning_overrides" "owned" {
  count       = var.enable_skill_scanning ? 1 : 0
  fingerprint = prisma-airs_supply_chain_skill_scanning_override.example[0].fingerprint
}

# Policy: Explicit opt-in changes one shared rule; destroy restores its captured baseline.
resource "prisma-airs_supply_chain_skill_scanning_rule" "policy" {
  count     = var.manage_skill_rule ? 1 : 0
  rule_uuid = var.skill_rule_uuid
  state     = var.skill_rule_state
}

output "skill_rule_count" {
  value = var.enable_skill_scanning ? try(length(data.prisma-airs_supply_chain_skill_scanning_rules.catalog[0].result.rules), null) : null
}

output "effective_skill_rule_count" {
  description = "Returned effective rule settings; null when the native list is unavailable."
  value       = var.enable_skill_scanning ? try(length(data.prisma-airs_supply_chain_skill_scanning_rule_instances.effective[0].result.rule_instances), null) : null
}

output "trust_fingerprint" {
  value = var.enable_skill_scanning ? prisma-airs_supply_chain_skill_scanning_override.example[0].fingerprint : null
}

output "adopted_rule_baseline" {
  sensitive = true
  value     = var.manage_skill_rule ? prisma-airs_supply_chain_skill_scanning_rule.policy[0].original_state : null
}
