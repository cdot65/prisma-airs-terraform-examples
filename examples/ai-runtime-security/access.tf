# Discovery: Opt in to tenant DLP and deployment-profile inventories.
data "prisma-airs_runtime_dlp_profiles" "catalog" {
  count = var.enable_runtime_discovery ? 1 : 0
  limit = 10
}

data "prisma-airs_runtime_deployment_profiles" "catalog" {
  count = var.enable_runtime_discovery || var.create_scanning_key ? 1 : 0
  limit = 100
}

locals {
  deployment_matches = var.create_scanning_key ? [
    for profile in data.prisma-airs_runtime_deployment_profiles.catalog[0].items : profile
    if profile.profile_name == var.deployment_profile_name
  ] : []
}

# Scanning access: Select a deployment profile by name; keep the app association disposable.
resource "prisma-airs_runtime_api_key" "scanner" {
  count                  = var.create_scanning_key ? 1 : 0
  api_key_name           = "${var.name_prefix}-key"
  auth_code              = try(one(local.deployment_matches).auth_code, null)
  rotation_time_interval = 90
  rotation_time_unit     = "days"
  created_by             = "terraform-example"
  cust_app               = "${var.name_prefix}-scanner"
  cust_env               = var.scanning_environment
  cust_cloud_provider    = var.scanning_cloud_provider

  lifecycle {
    precondition {
      condition     = length(local.deployment_matches) == 1
      error_message = "Choose exactly one named profile in the first 100 deployment records; adjust the lookup if necessary."
    }
  }
}

# Existing app: Import before apply; protect an external application from example cleanup.
resource "prisma-airs_runtime_customer_app" "existing" {
  count      = var.existing_customer_app_name == null ? 0 : 1
  app_name   = var.existing_customer_app_name
  updated_by = "terraform-example"

  lifecycle {
    prevent_destroy = true
  }
}

output "scanning_api_key" {
  description = "One-time scanning credential; imported keys cannot recover it."
  sensitive   = true
  value       = var.create_scanning_key ? prisma-airs_runtime_api_key.scanner[0].api_key : null
}

output "dlp_catalog_count" {
  value = var.enable_runtime_discovery ? data.prisma-airs_runtime_dlp_profiles.catalog[0].total_count : null
}
