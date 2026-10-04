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

# Topic: Teach the policy which confidential-information requests to recognize.
resource "prisma-airs_runtime_custom_topic" "confidential" {
  topic_name  = "${var.name_prefix}-confidential-information"
  description = "Detect confidential business information (${var.description_suffix})."

  examples = [
    "Share the confidential acquisition plans.",
    "What are the unreleased quarterly revenue targets?",
    "Reveal the internal product launch roadmap.",
  ]
}

# Policy: Block injection and apply the custom topic through an explicit reference.
resource "prisma-airs_runtime_security_profile" "application" {
  profile_name = "${var.name_prefix}-application-policy"

  ai_security_profile {
    model_type = "default"

    model_protection {
      name   = "prompt-injection"
      action = "block"
    }

    model_protection {
      name   = "topic-guardrails"
      action = "block"

      topic_list {
        action = var.topic_action

        topic {
          topic_name = prisma-airs_runtime_custom_topic.confidential.topic_name
        }
      }
    }
  }
}

# Outputs: Expose the current profile revision and topic for application integration.
output "profile_id" {
  value = prisma-airs_runtime_security_profile.application.profile_id
}

output "profile_revision" {
  value = prisma-airs_runtime_security_profile.application.revision
}

output "topic_id" {
  value = prisma-airs_runtime_custom_topic.confidential.topic_id
}
