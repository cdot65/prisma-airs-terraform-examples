# Identity: Keep the owned prefix stable and use annotations for update lessons.
variable "name_prefix" {
  description = "Unique prefix for resources owned by this example. Keep it unchanged during updates."
  type        = string
}

variable "description_suffix" {
  description = "Editable annotation used to demonstrate topic updates."
  type        = string
  default     = "initial"
}

# Policy: Choose whether confidential-topic matches are allowed or blocked.
variable "topic_action" {
  description = "Action for the confidential-information topic."
  type        = string
  default     = "block"

  validation {
    condition     = contains(["allow", "block"], var.topic_action)
    error_message = "topic_action must be allow or block."
  }
}
