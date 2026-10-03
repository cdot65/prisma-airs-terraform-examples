# Secrets: Describe an external secret; null leaves credentials in the environment.
variable "secret_manager" {
  description = "Optional reference to a real upstream secret; creates no external secret."
  type = object({
    manager_type = string
    secret_path  = string
    secret_key   = optional(string)
  })
  default = null

  validation {
    condition     = var.secret_manager == null ? true : contains(["aws_sm", "azure_kv", "hashicorp_vault"], var.secret_manager.manager_type)
    error_message = "Use aws_sm, azure_kv or hashicorp_vault."
  }
}

variable "secret_for_upstream" {
  description = "Upstream authenticated through the optional secret reference."
  type        = string
  default     = null

  validation {
    condition     = var.secret_for_upstream == null ? true : (var.secret_manager == null ? false : contains(keys(var.upstreams), var.secret_for_upstream))
    error_message = "secret_for_upstream requires a secret_manager and a configured upstream name."
  }
}

variable "secret_manager_auth" {
  description = "Native secret-manager authentication; load TF_VAR_secret_manager_auth."
  type        = any
  sensitive   = true
  default     = {}
}

# Developer access: Supply an existing workspace user; IAM stays external.
variable "developer_user_id" {
  description = "Existing workspace user's UUID; null skips the developer key."
  type        = string
  default     = null
}

# MCP: Enable the connection only when the upstream and Gateway endpoint are reachable.
variable "enable_mcp" {
  description = "Create an MCP integration, workspace binding and server."
  type        = bool
  default     = false
}

variable "mcp_url" {
  description = "Actual reachable HTTP MCP upstream."
  type        = string
  default     = "https://learn.microsoft.com/api/mcp"
}

variable "mcp_auth_type" {
  description = "Upstream MCP authentication type."
  type        = string
  default     = "none"
}

variable "mcp_configurations" {
  description = "Sensitive native MCP connection settings; supply through the environment."
  type        = any
  sensitive   = true
  default     = {}
}

# Deployment: Register settings without provisioning gateway infrastructure.
variable "enable_deployment_registration" {
  description = "Register a nondefault hybrid deployment; creates no infrastructure."
  type        = bool
  default     = false
}

variable "deployment_config" {
  description = "Optional native hybrid deployment settings."
  type        = any
  sensitive   = true
  default     = null
}

variable "deployment_auth_settings" {
  description = "Optional native hybrid inbound authentication settings."
  type        = any
  sensitive   = true
  default     = null
}

# Organization policy: Explicit opt-in; organization scope can affect other workspaces.
variable "enable_org_guardrail" {
  description = "Explicit opt-in to an organization-wide policy across all workspaces."
  type        = bool
  default     = false
}
