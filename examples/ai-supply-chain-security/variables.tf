variable "name_prefix" {
  description = "Unique prefix for resources owned by this example."
  type        = string
}

variable "description_suffix" {
  description = "Editable annotation used to demonstrate security-group updates."
  type        = string
  default     = "initial"
}
