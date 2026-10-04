# Released resource coverage

Provider **0.10.0**: **26 resources** and **27 data sources**. This table is checked against the installed Registry provider, not an unreleased checkout. Entries include optional and import-only lessons; see each product README for prerequisites and validation limits.

Run `python3 scripts/coverage.py` after installation to check freshness, or add `--write` to regenerate after adding a Terraform example.

| Kind | Terraform type | Example configuration |
| --- | --- | --- |
| data | `prisma-airs_gateway_configs` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_deployments` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_guardrails` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_integrations` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_mcp_integrations` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_mcp_servers` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_org_guardrails` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_providers` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_rate_limits` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_secret_references` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_service_api_keys` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_usage_limits` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_user_api_keys` | [ai-gateway/discovery.tf](../examples/ai-gateway/discovery.tf) |
| data | `prisma-airs_gateway_workspace` | [ai-gateway/workspace.tf](../examples/ai-gateway/workspace.tf) |
| data | `prisma-airs_gateway_workspaces` | [ai-gateway/workspace.tf](../examples/ai-gateway/workspace.tf) |
| data | `prisma-airs_runtime_deployment_profiles` | [ai-runtime-security/access.tf](../examples/ai-runtime-security/access.tf) |
| data | `prisma-airs_runtime_dlp_profiles` | [ai-runtime-security/access.tf](../examples/ai-runtime-security/access.tf) |
| data | `prisma-airs_supply_chain_security_rules` | [ai-supply-chain-security/main.tf](../examples/ai-supply-chain-security/main.tf) |
| data | `prisma-airs_supply_chain_skill_scanning_attack_chains` | [ai-supply-chain-security/skill-discovery.tf](../examples/ai-supply-chain-security/skill-discovery.tf) |
| data | `prisma-airs_supply_chain_skill_scanning_instance` | [ai-supply-chain-security/skill-instance.tf](../examples/ai-supply-chain-security/skill-instance.tf) |
| data | `prisma-airs_supply_chain_skill_scanning_overrides` | [ai-supply-chain-security/skills.tf](../examples/ai-supply-chain-security/skills.tf) |
| data | `prisma-airs_supply_chain_skill_scanning_rule_instances` | [ai-supply-chain-security/skills.tf](../examples/ai-supply-chain-security/skills.tf) |
| data | `prisma-airs_supply_chain_skill_scanning_rules` | [ai-supply-chain-security/skills.tf](../examples/ai-supply-chain-security/skills.tf) |
| data | `prisma-airs_supply_chain_skill_scanning_scan` | [ai-supply-chain-security/skill-discovery.tf](../examples/ai-supply-chain-security/skill-discovery.tf), [ai-supply-chain-security/skill-discovery.tf](../examples/ai-supply-chain-security/skill-discovery.tf) |
| data | `prisma-airs_supply_chain_skill_scanning_scans` | [ai-supply-chain-security/skill-discovery.tf](../examples/ai-supply-chain-security/skill-discovery.tf) |
| data | `prisma-airs_supply_chain_skill_scanning_statistics` | [ai-supply-chain-security/skill-discovery.tf](../examples/ai-supply-chain-security/skill-discovery.tf) |
| data | `prisma-airs_supply_chain_skill_scanning_vulnerabilities` | [ai-supply-chain-security/skill-discovery.tf](../examples/ai-supply-chain-security/skill-discovery.tf) |
| resource | `prisma-airs_gateway_config` | [ai-gateway/main.tf](../examples/ai-gateway/main.tf) |
| resource | `prisma-airs_gateway_deployment` | [ai-gateway/platform.tf](../examples/ai-gateway/platform.tf) |
| resource | `prisma-airs_gateway_guardrail` | [ai-gateway/main.tf](../examples/ai-gateway/main.tf), [ai-gateway/main.tf](../examples/ai-gateway/main.tf) |
| resource | `prisma-airs_gateway_integration` | [ai-gateway/main.tf](../examples/ai-gateway/main.tf) |
| resource | `prisma-airs_gateway_integration_workspace_binding` | [ai-gateway/main.tf](../examples/ai-gateway/main.tf) |
| resource | `prisma-airs_gateway_mcp_integration` | [ai-gateway/platform.tf](../examples/ai-gateway/platform.tf) |
| resource | `prisma-airs_gateway_mcp_integration_workspace_binding` | [ai-gateway/platform.tf](../examples/ai-gateway/platform.tf) |
| resource | `prisma-airs_gateway_mcp_server` | [ai-gateway/platform.tf](../examples/ai-gateway/platform.tf) |
| resource | `prisma-airs_gateway_org_guardrail` | [ai-gateway/platform.tf](../examples/ai-gateway/platform.tf) |
| resource | `prisma-airs_gateway_provider` | [ai-gateway/main.tf](../examples/ai-gateway/main.tf) |
| resource | `prisma-airs_gateway_rate_limit` | [ai-gateway/main.tf](../examples/ai-gateway/main.tf) |
| resource | `prisma-airs_gateway_secret_reference` | [ai-gateway/platform.tf](../examples/ai-gateway/platform.tf) |
| resource | `prisma-airs_gateway_service_api_key` | [ai-gateway/main.tf](../examples/ai-gateway/main.tf) |
| resource | `prisma-airs_gateway_usage_limit` | [ai-gateway/main.tf](../examples/ai-gateway/main.tf) |
| resource | `prisma-airs_gateway_user_api_key` | [ai-gateway/platform.tf](../examples/ai-gateway/platform.tf) |
| resource | `prisma-airs_gateway_workspace` | [ai-gateway/workspace.tf](../examples/ai-gateway/workspace.tf) |
| resource | `prisma-airs_red_team_custom_prompt_set` | [ai-red-teaming/main.tf](../examples/ai-red-teaming/main.tf) |
| resource | `prisma-airs_red_team_target` | [ai-red-teaming/main.tf](../examples/ai-red-teaming/main.tf) |
| resource | `prisma-airs_runtime_api_key` | [ai-runtime-security/access.tf](../examples/ai-runtime-security/access.tf) |
| resource | `prisma-airs_runtime_custom_topic` | [ai-runtime-security/main.tf](../examples/ai-runtime-security/main.tf) |
| resource | `prisma-airs_runtime_customer_app` | [ai-runtime-security/access.tf](../examples/ai-runtime-security/access.tf) |
| resource | `prisma-airs_runtime_security_profile` | [ai-gateway/main.tf](../examples/ai-gateway/main.tf), [ai-runtime-security/main.tf](../examples/ai-runtime-security/main.tf) |
| resource | `prisma-airs_supply_chain_security_group` | [ai-supply-chain-security/main.tf](../examples/ai-supply-chain-security/main.tf) |
| resource | `prisma-airs_supply_chain_skill_scanning_instance` | [ai-supply-chain-security/skill-instance.tf](../examples/ai-supply-chain-security/skill-instance.tf) |
| resource | `prisma-airs_supply_chain_skill_scanning_override` | [ai-supply-chain-security/skills.tf](../examples/ai-supply-chain-security/skills.tf) |
| resource | `prisma-airs_supply_chain_skill_scanning_rule` | [ai-supply-chain-security/skills.tf](../examples/ai-supply-chain-security/skills.tf) |
