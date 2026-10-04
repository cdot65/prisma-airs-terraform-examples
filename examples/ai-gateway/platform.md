# Optional Gateway platform capabilities

These options add resources to the same application state. Configure their real prerequisites, review the plan, and apply. Setting an option back to its default proposes removal of its owned resources. The [main guide](README.md) covers authentication and the request workflow.

## External secret reference

Provide a real secret path in AWS Secrets Manager, Azure Key Vault, or HashiCorp Vault and configure Gateway's access to that manager. This creates a reference; it does not provision the manager or its secret.

For example, with an existing AWS secret:

```hcl
secret_manager = {
  manager_type = "aws_sm"
  secret_path  = "your-application/upstream-key"
}
secret_for_upstream = "openai"
```

Supply the native authentication object through `TF_VAR_secret_manager_auth`; a service-role example uses `aws_auth_type = "serviceRole"` and the actual `aws_region`. Use `azure_kv` for Azure or `hashicorp_vault` for Vault, with their corresponding authentication fields. Follow the [secret-reference schema](https://cdot65.github.io/terraform-provider-prisma-airs/reference/generated/prisma-airs_gateway_secret_reference/) for your manager.

A reference can be created first with `secret_for_upstream = null`. When you select an upstream, the integration's `key` is omitted for `secret_for_upstream`, and its `secret_mappings` references the created secret reference. Other connections still require environment-supplied credentials. Workspace access is limited to this example's workspace. Verify a real inference request to establish secret retrieval; creation of the reference alone proves no such retrieval. The service may omit workspace access from refresh reads, which limits drift detection.

## Developer API key

Set `developer_user_id` to an existing authorized workspace user's UUID:

```hcl
developer_user_id = "existing-user-uuid"
```

Terraform creates a user key with completion scope and the fallback config. It does not create the user or grant workspace membership. Arrange membership and access grants outside this provider before enabling a user key for a new workspace. `developer_api_key` is sensitive one-time material retained in state. Destroy removes only this key.

## MCP tools

```hcl
enable_mcp = true
mcp_url    = "https://learn.microsoft.com/api/mcp"
```

This public upstream is the [Microsoft Learn MCP server](https://learn.microsoft.com/en-us/training/support/mcp). The project creates its own organization integration, explicit workspace binding, and MCP server, and adds `mcp.invoke` scope to the application service keys. Authenticated upstreams also need `mcp_auth_type` and sensitive `TF_VAR_mcp_configurations` settings.

Gateway deployment connectivity, capability discovery, tool access, and any guardrail mappings are outside the released Terraform resource. Complete those settings in SCM for the new server. Registration alone does not establish tool availability.

Set your deployment's MCP URL template with `{server_slug}` at the server identifier position, then initialize and list tools:

```bash
export PANW_AI_GW_MCP_ENDPOINT="https://YOUR-MCP-GATEWAY/{server_slug}/mcp"
python3 mcp-demo.py
```

After confirming that the advertised tool is available, an explicit read-only invocation is:

```bash
python3 mcp-demo.py --tool microsoft_docs_search --arguments '{"query":"Terraform"}'
```

The helper uses the owned server and application key, prints only status/counts, and closes a stateful session when one was issued. The URL shape is deployment-specific; copy the actual contract rather than using Terraform's management URL.

## Hybrid deployment registration

```hcl
enable_deployment_registration = true
```

This creates a `non_production` registration with `is_default = false`. Optional native settings can be supplied through sensitive `TF_VAR_deployment_config` and `TF_VAR_deployment_auth_settings`. `deployment_credentials` contains sensitive one-time credentials for external deployment setup.

The resource does not install containers, Helm charts, Kubernetes infrastructure, or networking. It does not connect the deployment, attach workspaces, or rotate authentication. Follow [deployment setup](https://docs.paloaltonetworks.com/prisma-airs/ai-gateway/configure-ai-gateway-hybrid) separately. Destroy archives the registration; its record can remain visible.

## Organization guardrail

```hcl
enable_org_guardrail = true
```

This creates an **organization-scoped** policy and explicitly attaches it to this project's four routing configs. Enable it deliberately in a suitable test tenant: organization policies can apply across workspaces. The example blocks only the unique `<name_prefix>_ORG_BLOCK` marker.

After apply, run `python3 demo.py --org-deny` to verify the owned policy's denial through an attached config. On the tested hybrid deployment, an unreferenced organization policy did not automatically deny this marker; explicit attachment succeeded. Automatic baseline enforcement across other workspaces requires separate deployment verification.

Provider 0.10.0 does not expose workspace exclusions or a writable request/response target. This option does not adopt or edit existing shared guardrails. Disable it and apply, or destroy the project, to remove the owned policy.

## Coverage and limits

Together with the default application, these options cover all **16 released Gateway resource types**, including [workspace ownership](README.md#own-a-workspace). The [current release evidence](../../docs/live-runs/provider-0.10.0.md) and [historical expanded run](../../docs/live-runs/ai-gateway-expanded.md) distinguishes lifecycle checks, runtime checks, and prerequisites that were unavailable. A disabled optional resource is schema-checked by `terraform validate`; that does not establish that your external secret store, deployment, identity, or MCP endpoint works.
