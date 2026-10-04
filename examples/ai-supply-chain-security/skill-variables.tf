# Access: Leave Skill Scanning disabled until its entitlement and endpoints are configured.
variable "enable_skill_scanning" {
  description = "Read Skill Scanning policy and create a disposable synthetic trust override."
  type        = bool
  default     = false
}

variable "enable_skill_history" {
  description = "Read one scan page and statistics from a Skill Scanning-enabled tenant."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_skill_history || var.enable_skill_scanning
    error_message = "Enable Skill Scanning before its history lesson."
  }
}

# Shared policy: A catalog rule UUID differs from its effective rule-instance UUID.
variable "manage_skill_rule" {
  description = "Explicitly adopt one tenant-wide rule; keep this rule in only one Terraform state."
  type        = bool
  default     = false

  validation {
    condition     = !var.manage_skill_rule || (var.enable_skill_scanning && var.skill_rule_uuid != null)
    error_message = "Rule management requires Skill Scanning and a catalog rule UUID."
  }
}

variable "skill_rule_uuid" {
  description = "Catalog UUID of the rule deliberately adopted for management."
  type        = string
  default     = null
}

variable "skill_rule_state" {
  description = "Desired state; the captured effective baseline is restored on destroy."
  type        = string
  default     = "BLOCKING"

  validation {
    condition     = contains(["DISABLED", "ALLOWING", "BLOCKING"], var.skill_rule_state)
    error_message = "Choose DISABLED, ALLOWING, or BLOCKING."
  }
}

# Existing results: All lookups require independent, already provisioned fixtures.
variable "skill_tenant_id" {
  description = "Optional tenant ID for read-only registration lookup; requires instance-read access."
  type        = string
  default     = null
}

variable "skill_scan_uuid" {
  description = "Optional existing scan UUID for detail, vulnerability, and attack-chain reads."
  type        = string
  default     = null
}

variable "existing_skill_fingerprint" {
  description = "Optional lowercase SHA-256 fingerprint of an already scanned skill."
  type        = string
  default     = null

  validation {
    condition     = var.existing_skill_fingerprint == null ? true : can(regex("^[0-9a-f]{64}$", var.existing_skill_fingerprint))
    error_message = "Use a 64-character lowercase SHA-256 fingerprint."
  }
}

# Onboarding: Complete desired metadata is sensitive and persists in state.
variable "manage_skill_instance" {
  description = "Explicitly own tenant onboarding; existing instances must be imported before first apply."
  type        = bool
  default     = false

  validation {
    condition     = !var.manage_skill_instance || (var.enable_skill_scanning && var.skill_instance != null)
    error_message = "Instance management requires Skill Scanning and the complete onboarding object."
  }
}

variable "skill_instance" {
  description = "Entire authorized onboarding payload; never reconstruct it from a partial GET response."
  type = object({
    tenant_id            = string
    support_account_id   = string
    created_by           = string
    support_account_name = optional(string)
    registration_details = any
    iam_controlled       = optional(bool)
  })
  sensitive = true
  default   = null
}

# Write-only: Terraform 1.11+ sends the code without saving it in plan or state.
variable "skill_auth_code" {
  description = "Load TF_VAR_skill_auth_code from the secret store; only used for managed registration."
  type        = string
  sensitive   = true
  ephemeral   = true
  default     = null

  validation {
    condition     = var.skill_auth_code == null || var.skill_auth_code_version != null
    error_message = "Set skill_auth_code_version when supplying an authorization code."
  }
}

variable "skill_auth_code_version" {
  description = "Increment to send or clear the write-only code; null makes no code change."
  type        = number
  default     = null
}
