# Access: Read-only discovery and key creation are separate optional lessons.
variable "enable_runtime_discovery" {
  description = "Read DLP and deployment-profile inventories from this tenant."
  type        = bool
  default     = false
}

variable "create_scanning_key" {
  validation {
    condition     = !var.create_scanning_key || length(var.name_prefix) <= 27
    error_message = "Scanning-key creation requires a name_prefix of at most 27 characters (the key name limit is 31)."
  }
  description = "Issue a scanning key associated only with this example's disposable customer app."
  type        = bool
  default     = false

  validation {
    condition     = !var.create_scanning_key || try(length(trimspace(var.deployment_profile_name)) > 0, false)
    error_message = "Key creation requires a named deployment profile."
  }
}

variable "deployment_profile_name" {
  description = "Unique deployment profile name in the first 100 records; auth codes stay sensitive."
  type        = string
  default     = null
}

# Adoption: This app is import-only and must be unrelated to the disposable scanning key.
variable "existing_customer_app_name" {
  description = "Optional existing customer app to import; prevent_destroy protects it during cleanup."
  type        = string
  default     = null

  validation {
    condition     = var.existing_customer_app_name == null ? true : (length(trimspace(var.existing_customer_app_name)) > 0 && var.existing_customer_app_name != "${var.name_prefix}-scanner")
    error_message = "Use an existing app name different from this example's disposable scanner app."
  }
}

# Application metadata: These labels describe the key's disposable app, not cloud infrastructure.
variable "scanning_environment" {
  description = "Customer application environment annotation for the scanning key."
  type        = string
  default     = "dev"
}

variable "scanning_cloud_provider" {
  description = "Customer application cloud annotation required by the live association workflow."
  type        = string
  default     = "aws"
}
