# Identity: Keep names stable and select existing or owned workspace access.
variable "name_prefix" {
  description = "Unique owned prefix and application metadata value; keep stable until destroy."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,39}$", var.name_prefix))
    error_message = "Use 3–40 lowercase letters, digits or hyphens, starting with a letter."
  }
}

variable "workspace_id" {
  description = "Existing Gateway workspace UUID; omit when create_workspace is true."
  type        = string
  default     = null

  validation {
    condition     = var.create_workspace ? var.workspace_id == null : try(length(trimspace(var.workspace_id)) > 0, false)
    error_message = "Supply workspace_id for an existing workspace, or omit it and set create_workspace = true."
  }
}

# Connections: Match named integrations to environment-supplied credentials.
variable "upstreams" {
  description = "Named model connections with provider-family UUIDs from the Gateway catalog."
  type = map(object({
    ai_provider_id = string
  }))

  validation {
    condition = length(var.upstreams) > 0 && alltrue([
      for k in keys(var.upstreams) : can(regex("^[a-z][a-z0-9-]*$", k))
    ])
    error_message = "Supply at least one upstream with lowercase names."
  }
}

variable "upstream_api_keys" {
  description = "Credentials keyed by upstream; load TF_VAR_upstream_api_keys as JSON."
  type        = map(string)
  sensitive   = true
  default     = {}

  validation {
    condition = alltrue([
      for k in keys(var.upstreams) :
      k == var.secret_for_upstream ? true : try(length(trimspace(var.upstream_api_keys[k])) > 0, false)
    ])
    error_message = "Every upstream needs an environment credential or the enabled secret reference."
  }
}

variable "upstream_configurations" {
  description = "Native provider-specific settings keyed by upstream; may contain secrets."
  type        = any
  sensitive   = true
  default     = {}
}

# Targets: Select enabled models and optionally a separate secondary connection.
variable "primary_upstream" {
  description = "Upstream name for the primary model."
  type        = string

  validation {
    condition     = contains(keys(var.upstreams), var.primary_upstream)
    error_message = "primary_upstream must name a configured upstream."
  }
}

variable "secondary_upstream" {
  description = "Optional second upstream; null uses the primary service with a second model."
  type        = string
  default     = null

  validation {
    condition     = var.secondary_upstream == null ? true : contains(keys(var.upstreams), var.secondary_upstream)
    error_message = "secondary_upstream must name a configured upstream."
  }
}

variable "primary_model" {
  description = "A chat model enabled on the primary integration."
  type        = string
}

variable "secondary_model" {
  description = "A different chat model enabled on the secondary integration."
  type        = string
}

# Updates: Change annotations while preserving resource identity.
variable "description_suffix" {
  description = "Editable integration annotation for the update lesson."
  type        = string
  default     = "initial"
}

# Routing controls: Bound retries, adjust weights, and set cache lifetime.
variable "retry_attempts" {
  description = "Fallback retry count, from zero through three."
  type        = number
  default     = 1

  validation {
    condition     = var.retry_attempts >= 0 && var.retry_attempts <= 3 && floor(var.retry_attempts) == var.retry_attempts
    error_message = "retry_attempts must be an integer from 0 through 3."
  }
}

variable "fallback_status_codes" {
  description = "Upstream status codes that advance to the secondary target."
  type        = list(number)
  default     = [429, 500, 502, 503, 504]

  validation {
    condition = length(var.fallback_status_codes) > 0 && alltrue([
      for c in var.fallback_status_codes : c >= 400 && c <= 599 && floor(c) == c
    ])
    error_message = "Supply one or more integer HTTP error codes from 400 through 599."
  }
}

variable "primary_weight" {
  description = "Primary target's percentage of balanced traffic."
  type        = number
  default     = 50

  validation {
    condition     = var.primary_weight > 0 && var.primary_weight < 100
    error_message = "primary_weight must be greater than 0 and less than 100."
  }
}

variable "cache_max_age" {
  description = "Simple-cache lifetime in seconds."
  type        = number
  default     = 60

  validation {
    condition     = var.cache_max_age > 0 && floor(var.cache_max_age) == var.cache_max_age
    error_message = "cache_max_age must be a positive integer."
  }
}

# Limits: Match application metadata; changes do not reset accumulated usage.
variable "requests_per_minute" {
  description = "Request limit for the application metadata."
  type        = number
  default     = 100

  validation {
    condition     = var.requests_per_minute > 0 && floor(var.requests_per_minute) == var.requests_per_minute
    error_message = "requests_per_minute must be a positive integer."
  }
}

variable "token_budget" {
  description = "Monthly token budget; Terraform does not reset used credits."
  type        = number
  default     = 100000

  validation {
    condition     = var.token_budget >= 2 && floor(var.token_budget) == var.token_budget
    error_message = "token_budget must be an integer of at least 2, allowing a positive alert threshold below the budget."
  }
}
