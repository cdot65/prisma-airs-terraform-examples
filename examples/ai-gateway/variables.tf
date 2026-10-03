variable "name_prefix" {
  description = "Unique prefix and request metadata.application value for this example."
  type        = string
}

variable "workspace_id" {
  description = "Existing Gateway workspace UUID; this project does not manage it."
  type        = string
}

variable "provider_slug" {
  description = "Slug of an existing enabled provider in the chosen workspace, without @."
  type        = string
}

variable "model" {
  description = "Model available through the existing provider integration."
  type        = string
}

variable "retry_attempts" {
  description = "Number of retry attempts in the routing document."
  type        = number
  default     = 1
}

variable "requests_per_minute" {
  description = "Rate threshold for requests carrying this example's application metadata."
  type        = number
  default     = 100
}
