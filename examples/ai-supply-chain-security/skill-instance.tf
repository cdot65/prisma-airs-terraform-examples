# Registration: Import existing instances before apply; PUT owns the complete onboarding payload.
resource "prisma-airs_supply_chain_skill_scanning_instance" "tenant" {
  count                = var.manage_skill_instance ? 1 : 0
  tenant_id            = var.skill_instance.tenant_id
  support_account_id   = var.skill_instance.support_account_id
  created_by           = var.skill_instance.created_by
  support_account_name = var.skill_instance.support_account_name
  registration_details = var.skill_instance.registration_details
  iam_controlled       = var.skill_instance.iam_controlled
  auth_code            = var.skill_auth_code
  auth_code_version    = var.skill_auth_code_version

  lifecycle {
    prevent_destroy = true
  }
}

# Read-only: Tenant metadata can contain deployment authorization codes; do not print it.
data "prisma-airs_supply_chain_skill_scanning_instance" "existing" {
  count     = var.skill_tenant_id == null ? 0 : 1
  tenant_id = var.skill_tenant_id
}
