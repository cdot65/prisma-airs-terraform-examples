mock_provider "prisma-airs" {
  mock_data "prisma-airs_gateway_ai_providers" {
    defaults = {
      ids_by_slug = {
        open-ai   = "11111111-1111-4111-8111-111111111111"
        anthropic = "22222222-2222-4222-8222-222222222222"
      }
    }
  }
}

variables {
  workspace_id = "33333333-3333-4333-8333-333333333333"
  upstream_api_keys = {
    open-ai   = "mock-openai-key"
    anthropic = "mock-anthropic-key"
  }
}

run "resolve_both_provider_families" {
  command = plan

  assert {
    condition = (
      prisma-airs_gateway_integration.chat["open-ai"].ai_provider_id == "11111111-1111-4111-8111-111111111111" &&
      prisma-airs_gateway_integration.chat["anthropic"].ai_provider_id == "22222222-2222-4222-8222-222222222222"
    )
    error_message = "Each connection must use the UUID discovered for its catalog slug."
  }

  assert {
    condition = (
      prisma-airs_gateway_config.chat["open-ai"].config.override_params.model == "gpt-4.1" &&
      prisma-airs_gateway_config.chat["anthropic"].config.override_params.model == "claude-opus-4-6" &&
      length(prisma-airs_gateway_integration_workspace_binding.chat) == 2 &&
      length(prisma-airs_gateway_service_api_key.chat) == 2
    )
    error_message = "Both services need a model route, workspace authorization, and application key."
  }
}

run "reject_missing_anthropic_key" {
  command = plan
  variables {
    upstream_api_keys = { open-ai = "mock-openai-key" }
  }
  expect_failures = [var.upstream_api_keys]
}

run "reject_missing_model" {
  command = plan
  variables {
    models = { open-ai = "gpt-4.1" }
  }
  expect_failures = [var.models]
}
