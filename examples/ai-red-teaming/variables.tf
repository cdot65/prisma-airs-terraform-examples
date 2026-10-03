variable "name_prefix" {
  description = "Unique prefix for resources owned by this example."
  type        = string
}

variable "description_suffix" {
  description = "Editable annotation used to demonstrate target and prompt-set updates."
  type        = string
  default     = "initial"
}

variable "target_endpoint" {
  description = "HTTPS endpoint of an application you are authorized to assess."
  type        = string
  validation {
    condition     = startswith(var.target_endpoint, "https://")
    error_message = "Supply an HTTPS target endpoint."
  }
}

variable "request_body" {
  description = "Native request object containing the {INPUT} substitution marker."
  type        = any
}

variable "response_body" {
  description = "Native response template containing the {RESPONSE} substitution marker."
  type        = any
}

variable "response_key" {
  description = "Response field containing the model's text."
  type        = string
}

variable "target_auth_headers" {
  description = "Authentication headers supplied through TF_VAR_target_auth_headers."
  type        = map(string)
  sensitive   = true
}
