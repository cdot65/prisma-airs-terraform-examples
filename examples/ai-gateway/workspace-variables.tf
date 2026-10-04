# Ownership: Managed scopes are newly created; external scopes receive no IAM writes.
variable "create_workspace" {
  description = "Create an owned workspace instead of referencing workspace_id."
  type        = bool
  default     = false
}

variable "workspace_scope_name" {
  description = "Unused dedicated IAM scope name in managed mode, or a preexisting external scope name."
  type        = string
  default     = null

  validation {
    condition     = !var.create_workspace || try(length(trimspace(var.workspace_scope_name)) > 0, false)
    error_message = "Creating a workspace requires an explicit workspace_scope_name."
  }
}

variable "workspace_scope_management" {
  description = "managed owns a dedicated scope; external only references its owner-managed scope."
  type        = string
  default     = "managed"

  validation {
    condition     = contains(["managed", "external"], var.workspace_scope_management)
    error_message = "Choose managed or external scope ownership."
  }
}

# Policies: Leave workspace rates unmanaged unless explicitly supplied.
variable "workspace_rate_limits" {
  description = "Optional complete workspace rate collection; null leaves new workspace rates unmanaged."
  type = list(object({
    type  = string
    unit  = string
    value = number
  }))
  default = null
}

variable "enable_platform_discovery" {
  description = "Read the optional Gateway platform inventory; needs access to each enabled family."
  type        = bool
  default     = false
}

# Defaults: Supply the tenant-approved keys and all mandatory workspace metadata.
variable "workspace_default_metadata" {
  description = "Tenant-approved workspace metadata; supply every required field when creating a workspace."
  type        = map(string)
  default     = null

  validation {
    condition     = !var.create_workspace || var.workspace_default_metadata != null
    error_message = "Supply tenant-approved workspace_default_metadata for an owned workspace; use {} only if the tenant permits empty metadata."
  }
}
