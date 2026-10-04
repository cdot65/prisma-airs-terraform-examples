# Get started with AI Gateway

Build a governed AI application in an existing Gateway workspace. This project creates its upstream model connections, binds them to the workspace, configures routing and AIRS inspection, and gives your application a credential with request and token limits.

Four saved routing policies teach fallback/retry, weighted balancing, conditional routing, and simple caching. Optional features cover external secret references, developer keys, MCP, hybrid deployment registration, and organization guardrails in the same Terraform root.

## Discover upstream provider IDs

For OpenAI GPT and Anthropic Claude Opus connections selected by readable catalog slug, start with the [provider catalog example](provider-catalog/README.md). It discovers provider-family UUIDs inside Terraform; no manual UUID input is needed. That example pins provider 0.11.0 and installs directly from the Terraform Registry. The expanded project below remains the published 0.10.0 compatibility configuration.

## Before you start

You need:

- Terraform 1.11 or later, before 2.0. The root pins provider 0.10.0.
- The three [management environment variables](../../README.md#get-started), with Gateway and Runtime Security management access.
- An existing Gateway workspace UUID and a connected Gateway inference deployment.
- Usable upstream credentials and two routing targets: different models, different services, or separate connections to the same service.
- The tenant's **PANW Prisma AIRS plugin** configured with its inspection endpoint and Runtime Security API key. This project creates a dedicated security profile, but plugin administration is external. See [PANW plugin setup](https://docs.paloaltonetworks.com/prisma-airs/ai-gateway/ai-gateway-guardrails/configure-ai-runtime-api-guardrail).

Your inference endpoint differs from Terraform's management API endpoints. Copy the inference base URL from your deployment, including `/v1`. Optional capabilities have additional prerequisites in [platform.md](platform.md).

## Configure your application

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit the nonsecret input file:

| Input | What to supply |
| --- | --- |
| `name_prefix` | An unused lowercase prefix, 3–40 characters; keep it stable |
| `workspace_id` | Existing workspace UUID, omitted when `create_workspace = true` |
| `upstreams` | Legacy 0.10.0 connection inputs; use the catalog example above for automatic UUID discovery |
| `primary_upstream` | Name of the primary connection |
| `primary_model` | Primary model enabled on that connection |
| `secondary_model` | Second model on the same service by default |
| `secondary_upstream` | Optional different connection for the second model |

For this legacy 0.10.0 project, locate the existing workspace with your tenant selected:

```bash
airs cli aigateway workspaces list
```

Provider-family discovery for new projects is demonstrated in the [catalog example](provider-catalog/README.md); prefer that workflow over copying UUIDs.

Load `TF_VAR_upstream_api_keys` from your credential store as a JSON map keyed by the names in `upstreams`. Each connection needs its own value, even if two connections use the same account. Do not store this map in `terraform.tfvars`. For the sample `openai` connection, the environment variable contains this JSON shape (replace the placeholder through your credential store):

```json
{"openai": "<upstream-api-key>"}
```

For an OpenAI-compatible custom service, load `TF_VAR_upstream_configurations` as a JSON map containing its `provider_auth_type = "apiKey"` and `custom_host` settings. The [provider connection guide](https://cdot65.github.io/prisma-airs-sdk/guides/ai-gateway-api/) describes this contract. These settings are sensitive because provider-specific configurations can contain credentials. Its environment JSON shape is:

```json
{"openai": {"provider_auth_type": "apiKey", "custom_host": "https://YOUR-MODEL-SERVICE/v1"}}
```

For the standard OpenAI service, leave `upstream_configurations` at its empty default.

## Own a workspace

The default uses an existing workspace. To demonstrate provider 0.10.0 workspace management, remove `workspace_id` from your input file and set:

```hcl
# Workspace: Own a new workspace and its dedicated IAM scope.
create_workspace           = true
workspace_scope_name       = "tf_gateway_yourname"
workspace_scope_management = "managed"
```

Use an unused scope name and an account with Gateway admin, IAM permissions, and the necessary existing role grants. Scope binding associates the workspace slug; it does not grant roles or install Gateway infrastructure. All child resources use the selected UUID, so Terraform cleans them before archiving the workspace and confirming deletion of the owned scope.

A developer user key requires `developer_user_id` to identify an existing member of the selected workspace. A newly created workspace needs membership and access grants arranged outside this provider before enabling that key.

For a preexisting external scope, set `workspace_scope_management = "external"`. Its owner must maintain bindings and grants; Terraform makes no IAM writes. Never switch an existing state between workspace modes as an upgrade shortcut: first review the planned replacements and cleanup.

Supply `workspace_default_metadata` with the keys and values permitted by your tenant's Gateway metadata schema, including every required property. Load that map from the environment as `TF_VAR_workspace_default_metadata`, or use nonsecret sample inputs. Use `{}` only when the tenant permits empty metadata. Arbitrary keys or missing required properties produce HTTP 400; there is no universal valid metadata object.

Optional `workspace_rate_limits` owns the entire workspace rate collection. Removing previously configured limits clears them. The application already manages its token budget; do not create a second inline workspace usage policy, because the service permits one usage policy per workspace. Do not make workspace defaults reference a child config during creation, which would form a dependency cycle.

`workspace` always reports the selected UUID and ownership. Its slug comes from the owned resource, or from optional discovery for an existing workspace; otherwise it is null. `enable_platform_discovery = true` adds workspace and platform metadata reads, requiring the corresponding admin access. `platform_page_counts` shows returned item counts after owned writes, not exhaustive inventories. Changes by other users can alter these counts on refresh without a managed-resource diff. Inventory completeness is null when discovery is off; an omitted API pagination flag makes it false when enabled. Matching list rows cannot establish exclusive scope ownership.

Disable platform discovery before recovering a missing or archived workspace: the singular lookup rejects those identities. Follow the [workspace recovery guide](https://cdot65.github.io/terraform-provider-prisma-airs/resources/gateway-workspace/) and account for child resources whose archived workspace no longer allows reads.

For import, recovery after partial failures, and managed/external cleanup, use the [workspace guide](https://cdot65.github.io/terraform-provider-prisma-airs/resources/gateway-workspace/). Preserve state checkpoints; verify the exact workspace and dedicated scope before adopting either.

## Apply

```bash
terraform init
terraform plan -out=create.tfplan
terraform apply create.tfplan
terraform output routing
```

With one upstream and optional features disabled, the root creates **16 resources**: an integration/binding/provider chain, one Runtime Security profile, two guardrails, four routing configs, four application keys, and two usage policies. Each additional upstream adds three resources.

`routing` reports each policy's IDs and version. `application_keys` holds the four sensitive, one-time application credentials; the request helpers read these from state without printing them. Protect state and saved plans. Every key selects its saved config and disallows config overrides.

Model enablement and custom-model registration are outside provider 0.10.0. Check model access in SCM after creating an integration, and enable/register models there where your provider requires it. A successful apply does not establish upstream connectivity.

## Send your first request

Set your actual HTTPS inference base URL in the environment:

```bash
export PANW_AI_GW_INFERENCE_ENDPOINT="https://YOUR-GATEWAY/v1"
python3 demo.py --mode fallback
```

The helper sends an OpenAI-compatible chat request using the fallback application key and this example's application metadata. It bounds output to 32 tokens and prints HTTP status, returned model, and cache status. Python 3 and Terraform on PATH are required. It performs no automatic retries.

A successful request must return HTTP 200 with model text. Authentication, missing models, unavailable upstreams, and AIRS plugin errors are failures; check Gateway request logs rather than treating a configured resource as proof of a callable application.

Demonstrate the two security controls:

```bash
python3 demo.py --deny
python3 demo.py --attack
```

The first sends `AIRS_DEMO_BLOCK` and verifies that the **contains check** denied it. The second sends a controlled injection probe and requires an AIRS result reporting injection detection and a block. Both checks distinguish an actual guardrail verdict from authentication, provider, or plugin errors.

Sanitized live output recorded for these controls:

```text
fallback: default.contains denied probe (HTTP 446)
fallback: panw-prisma-airs.intercept denied probe (HTTP 446)
```

See [historical provider 0.9.0 run evidence](../../docs/live-runs/ai-gateway-expanded.md) for the configuration and request behaviors actually tested. The [earlier two-resource run](../../docs/live-runs/ai-gateway.md) is historical evidence for the original basic example.

## Explore routing

| Policy | Commands | What to observe |
| --- | --- | --- |
| Fallback/retry | `python3 demo.py --mode fallback` | Ordered targets; healthy traffic alone does not exercise failover |
| Weighted balancing | `python3 demo.py --mode balanced --repeat 12` | Distribution in Gateway request logs; a small random sample cannot prove an exact ratio |
| Conditional | `python3 demo.py --mode conditional --tier standard`, then `--tier premium` | Standard selects primary; premium selects secondary |
| Simple cache | `python3 demo.py --mode cached --repeat 2` | Repeat the identical request and check a cache-hit header or Gateway logs |

The first successful fallback request proves connectivity. To demonstrate a failover, use a disposable primary upstream that returns one of the configured retry/fallback status codes while the secondary remains healthy; do not disrupt a shared connection. Semantic caching is not configured by this project.

The default request limit is 100 requests/minute and the monthly token budget is 100,000, matched by `metadata.application`. Edit `requests_per_minute` or `token_budget`, review a plan, and apply it to explore enforcement. Terraform does not reset accumulated usage. Keep requests carrying the application metadata; these policies match that metadata, not arbitrary workspace traffic.

See [routing and policy lessons](routing-lessons.md) for a controlled failover and enforcement exercises. Request metadata is caller-supplied: these examples demonstrate policies matched to that metadata, rather than a tamper-proof application identity.

## Make a change and clean up

Edit `description_suffix`, `retry_attempts`, `primary_weight`, or the policy thresholds:

```bash
terraform plan -out=update.tfplan
terraform apply update.tfplan
```

Routing document changes preserve the config ID and advance its version. Terraform sends the complete routing document, including hooks.

Remove the example using the same tenant, inputs, and state:

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Destroy removes the owned keys, controls, providers, and integration bindings. It deletes all revisions of the owned Runtime profile. Hybrid registrations are archived. External workspaces, model services, tenant plugin settings, and secret-store contents remain prerequisites.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Management 401/403 | OAuth variables, TSG ID, Gateway/Runtime roles and entitlements |
| Apply succeeds but inference fails | Connected deployment, upstream credential, model enablement, and custom-host reachability |
| New config is not visible yet | Wait at least a minute for data-plane propagation, then inspect request logs |
| AIRS check errors | Tenant plugin endpoint/key and access to the created security profile |
| Unexpected request policy behavior | Application metadata, aggregation window, and accumulated token usage |
| Optional feature fails | Its prerequisites and supported ownership boundary in [platform.md](platform.md) |

[Provider Gateway workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/gateway-workflow/) · [Validation details](../../docs/validation.md)

[Provider 0.10.0 live evidence](../../docs/live-runs/provider-0.10.0.md) · [Complete release coverage](../../docs/resource-coverage.md)
