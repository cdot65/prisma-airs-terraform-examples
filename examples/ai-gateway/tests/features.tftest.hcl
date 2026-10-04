mock_provider "prisma-airs" {}
variables {
  name_prefix       = "tf-test-gateway"
  workspace_id      = "11111111-1111-4111-8111-111111111111"
  upstreams         = { primary = { ai_provider_id = "22222222-2222-4222-8222-222222222222" } }
  upstream_api_keys = { primary = "mock-upstream-key" }
  primary_upstream  = "primary"
  primary_model     = "fixture-primary"
  secondary_model   = "fixture-secondary"
}
run "existing_workspace" {
  command = plan
  assert {
    condition     = length(prisma-airs_gateway_workspace.application) == 0 && local.workspace_id == var.workspace_id
    error_message = "Existing-workspace users must keep the supplied external workspace."
  }
}
run "owned_workspace" {
  command = plan
  variables {
    workspace_id               = null
    create_workspace           = true
    workspace_default_metadata = {}
    workspace_scope_name       = "tf_test_owned_scope"
    enable_platform_discovery  = true
  }
  assert {
    condition     = length(prisma-airs_gateway_workspace.application) == 1 && prisma-airs_gateway_workspace.application[0].scope_management == "managed"
    error_message = "Owned mode must create a dedicated scope and workspace graph."
  }
}
run "external_scope" {
  command = plan
  variables {
    workspace_id               = null
    create_workspace           = true
    workspace_default_metadata = {}
    workspace_scope_name       = "fixture_external_scope"
    workspace_scope_management = "external"
  }
  assert {
    condition     = prisma-airs_gateway_workspace.application[0].scope_management == "external"
    error_message = "External scope mode must preserve external IAM ownership."
  }
}
run "reject_ambiguous_workspace" {
  command = plan
  variables {
    create_workspace           = true
    workspace_default_metadata = {}
    workspace_scope_name       = "tf_test_owned_scope"
  }
  expect_failures = [var.workspace_id]
}
