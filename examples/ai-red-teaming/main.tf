# Setup: Pin the provider and Terraform versions used by this example.
terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    prisma-airs = {
      source  = "cdot65/prisma-airs"
      version = "= 0.10.0"
    }
  }
}

# Authentication: Read management credentials from PANW_MGMT_* environment variables.
provider "prisma-airs" {}

# Target: Describe the application endpoint, payload templates, and authentication.
resource "prisma-airs_red_team_target" "application" {
  name        = "${var.name_prefix}-application-target"
  description = "Application assessment target (${var.description_suffix})."
  target_type = "APPLICATION"

  custom {
    api_endpoint    = var.target_endpoint
    request_headers = { "Content-Type" = "application/json" }
    request_body    = var.request_body
    response_body   = var.response_body
    response_key    = var.response_key
  }

  headers_auth {
    headers = var.target_auth_headers
  }
}

# Prompts: Create a container; populate prompts and run assessments separately.
resource "prisma-airs_red_team_custom_prompt_set" "assessment" {
  name        = "${var.name_prefix}-assessment-prompts"
  description = "Custom assessment prompt collection (${var.description_suffix})."
}

# Outputs: Locate the owned target and prompt set when preparing an assessment.
output "target_id" {
  value = prisma-airs_red_team_target.application.uuid
}

output "prompt_set_id" {
  value = prisma-airs_red_team_custom_prompt_set.assessment.uuid
}
