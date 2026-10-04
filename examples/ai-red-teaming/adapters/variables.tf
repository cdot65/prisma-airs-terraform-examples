# Identity: Choose unused names for the resources owned by this project.
variable "name_prefix" {
  description = "Unique adapter and target name prefix."
  type        = string
  default     = "tf-redteam-adapter"
}

# Execution: Enable only after inspecting the script and existing broker channel.
variable "activate" {
  description = "Execute adapter validation and register its target."
  type        = bool
  default     = false
}

variable "network_broker_channel_uuid" {
  description = "Existing online channel with text adapter support; required for activation."
  type        = string
  default     = null
}

# Variables: Keep every imported key; null retains an existing SECRET value.
variable "adapter_variables" {
  description = "Complete desired variable key set. Load SECRET values from your secret store."
  type = map(object({
    type  = string
    value = optional(string)
  }))
  sensitive = true
  default = {
    message = {
      type  = "VAR"
      value = "Terraform adapter is reachable"
    }
  }
}
