# History: Read one page of scans and nullable statistics; no uploads or jobs are started.
data "prisma-airs_supply_chain_skill_scanning_scans" "history" {
  count          = var.enable_skill_history ? 1 : 0
  limit          = 10
  statuses       = ["COMPLETED", "FAILED"]
  artifact_types = ["SKILL"]
}

data "prisma-airs_supply_chain_skill_scanning_statistics" "summary" {
  count       = var.enable_skill_history ? 1 : 0
  time_period = "7_DAYS"
}

# Findings: Supply an existing scan UUID; full results stay sensitive in Terraform state.
data "prisma-airs_supply_chain_skill_scanning_scan" "selected" {
  count     = var.skill_scan_uuid == null ? 0 : 1
  scan_uuid = var.skill_scan_uuid
}

data "prisma-airs_supply_chain_skill_scanning_vulnerabilities" "selected" {
  count     = var.skill_scan_uuid == null ? 0 : 1
  scan_uuid = var.skill_scan_uuid
  limit     = 10
  in_chain  = false
}

data "prisma-airs_supply_chain_skill_scanning_attack_chains" "selected" {
  count     = var.skill_scan_uuid == null ? 0 : 1
  scan_uuid = var.skill_scan_uuid
  limit     = 10
}

# Lookup: Alternatively discover the latest scan for an already scanned fingerprint.
data "prisma-airs_supply_chain_skill_scanning_scan" "fingerprint" {
  count       = var.existing_skill_fingerprint == null ? 0 : 1
  fingerprint = var.existing_skill_fingerprint
}

output "skill_statistics" {
  description = "Nullable native statistics; unavailable fields do not mean zero."
  sensitive   = true
  value       = var.enable_skill_history ? data.prisma-airs_supply_chain_skill_scanning_statistics.summary[0].result : null
}
