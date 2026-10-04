mock_provider "prisma-airs" {}
variables {
  name_prefix = "tf-test-runtime"
}
run "policy_only" {
  command = plan
  assert {
    condition     = length(prisma-airs_runtime_api_key.scanner) == 0 && length(prisma-airs_runtime_customer_app.existing) == 0
    error_message = "Default policy exercise must not issue keys or adopt external applications."
  }
}
run "reject_unavailable_deployment_profile" {
  command = plan
  variables {
    enable_runtime_discovery = true
    create_scanning_key      = true
    deployment_profile_name  = "missing-profile"
  }
  expect_failures = [prisma-airs_runtime_api_key.scanner[0]]
}
run "existing_application" {
  command = plan
  variables {
    existing_customer_app_name = "existing-fixture"
  }
  assert {
    condition     = length(prisma-airs_runtime_customer_app.existing) == 1
    error_message = "Explicit application adoption must have an import address."
  }
}
run "reject_cascading_app_association" {
  command = plan
  variables {
    existing_customer_app_name = "tf-test-runtime-scanner"
  }
  expect_failures = [var.existing_customer_app_name]
}
