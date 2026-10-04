mock_provider "prisma-airs" {
  mock_data "prisma-airs_supply_chain_skill_scanning_overrides" {
    defaults = { result = { skill_overrides = [{}] } }
  }
  mock_data "prisma-airs_supply_chain_skill_scanning_rules" {
    defaults = {
      result = { rules = [] }
    }
  }
}

variables {
  name_prefix = "tf-test-supply"
}

run "model_only" {
  command = plan
  assert {
    condition     = length(prisma-airs_supply_chain_skill_scanning_override.example) == 0 && length(prisma-airs_supply_chain_skill_scanning_instance.tenant) == 0 && length(prisma-airs_supply_chain_skill_scanning_rule.policy) == 0
    error_message = "Default exercise must not change Skill Scanning settings."
  }
}

run "policy_trust_and_history" {
  command = apply
  variables {
    enable_skill_scanning      = true
    enable_skill_history       = true
    manage_skill_rule          = true
    skill_rule_uuid            = "11111111-1111-4111-8111-111111111111"
    skill_scan_uuid            = "22222222-2222-4222-8222-222222222222"
    skill_tenant_id            = "fixture-tenant"
    existing_skill_fingerprint = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }
  assert {
    condition     = length(prisma-airs_supply_chain_skill_scanning_override.example) == 1 && length(prisma-airs_supply_chain_skill_scanning_rule.policy) == 1 && length(data.prisma-airs_supply_chain_skill_scanning_attack_chains.selected) == 1 && length(data.prisma-airs_supply_chain_skill_scanning_scan.fingerprint) == 1 && output.trust_override_matches == 1
    error_message = "Enabled policy and existing-result lessons must build their dependency graph."
  }
}

run "registration_with_write_only_code" {
  command = plan
  variables {
    enable_skill_scanning   = true
    manage_skill_instance   = true
    skill_auth_code         = "mock-write-only-code"
    skill_auth_code_version = 1
    skill_instance = {
      tenant_id          = "fixture-tenant"
      support_account_id = "fixture-account"
      created_by         = "terraform@example.com"
      registration_details = {
        region        = "us"
        license_name  = "fixture-license"
        entitlements  = []
        tsg_instances = []
      }
    }
  }
  assert {
    condition     = length(prisma-airs_supply_chain_skill_scanning_instance.tenant) == 1
    error_message = "The explicit onboarding lesson must plan a registration resource."
  }
}

run "reject_missing_rule_identity" {
  command = plan
  variables {
    enable_skill_scanning = true
    manage_skill_rule     = true
  }
  expect_failures = [var.manage_skill_rule]
}

run "missing_native_rule_list" {
  command = plan
  variables {
    enable_skill_scanning = true
  }
  override_data {
    target = data.prisma-airs_supply_chain_skill_scanning_rules.catalog[0]
    values = { result = {} }
  }
  assert {
    condition     = output.skill_rule_count == null
    error_message = "Unavailable native rule lists must remain null rather than break a plan or report zero."
  }
}
run "reject_unversioned_authorization_code" {
  command = plan
  variables {
    skill_auth_code = "mock-write-only-code"
  }
  expect_failures = [var.skill_auth_code]
}

run "reject_lookups_without_skill_scanning" {
  command = plan
  variables {
    skill_tenant_id            = "fixture-tenant"
    skill_scan_uuid            = "22222222-2222-4222-8222-222222222222"
    existing_skill_fingerprint = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }
  expect_failures = [var.skill_tenant_id, var.skill_scan_uuid, var.existing_skill_fingerprint]
}
