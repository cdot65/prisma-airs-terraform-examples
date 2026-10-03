# Expanded Gateway live run — 2026-10-03

Recorded on the vulture tenant using Terraform 1.16.4 and the signed Registry provider 0.9.0. This is supporting evidence for the [getting-started guide](../../examples/ai-gateway/README.md), not a prerequisite checklist.

Public excerpts are sanitized: credentials are omitted, and model names, endpoints, tenant and resource identifiers are replaced by placeholders or omitted. Summary lines retain the actual Terraform results.

## Fixture configuration

The final lifecycle enabled every optional feature and used two owned OpenAI-compatible integrations to one MLX backend/model, an existing workspace, and an existing user authorized in that workspace. It created **26 resources**, covering all **15 Gateway resource types** plus one Runtime Security profile. With a single upstream and options disabled, the default project creates 16 resources.

The workspace, user, tenant AIRS plugin, inference/MCP deployments, and upstream service were existing prerequisites. Management and upstream credentials were supplied as environment variables. The secret reference used AWS service-role metadata with an unbound disposable path; no external secret was provisioned or retrieved. The hybrid registration was nondefault and nonproduction.

## Final configuration lifecycle

The exact HCL identified in [the receipt](../validation-receipts.json) was installed, validated, planned, and applied:

```text
$ terraform init -lockfile=readonly
$ terraform validate
Success! The configuration is valid.
$ terraform plan -out=create.tfplan
Plan: 26 to add, 0 to change, 0 to destroy.
$ terraform apply create.tfplan
Apply complete! Resources: 26 added, 0 changed, 0 destroyed.
$ terraform plan -detailed-exitcode
No changes. Your infrastructure matches the configuration.
# Exit code: 0
```

The update changed integration descriptions, retries from 1 to 2, primary weight from 50 to 60, requests/minute from 100 to 120, and token budget from 100,000 to 110,000:

```text
$ terraform plan -out=update.tfplan
Plan: 0 to add, 6 to change, 0 to destroy.
$ terraform apply update.tfplan
Apply complete! Resources: 0 added, 6 changed, 0 destroyed.
$ terraform apply -refresh-only
$ terraform plan -detailed-exitcode
No changes. Your infrastructure matches the configuration.
# Exit code: 0
```

Routing IDs stayed stable and changed routing documents received new version IDs. The final cleanup and independent API checks are summarized below.

## Real application outcomes

The final configuration completed these bounded request checks:

| Check | Recorded outcome |
| --- | --- |
| Benign inference | HTTP 200 with model text |
| Deterministic marker | HTTP 446; owned `default.contains` check failed |
| AIRS prompt injection | HTTP 446; owned `panw-prisma-airs.intercept` check reported injection and block without a scanner error |
| Conditional standard/premium | HTTP 200; selected `config.targets[0]` / `config.targets[1]` |
| Simple cache | HTTP 200; identical repeated request returned MISS then HIT |
| Weighted balancing | 12 HTTP 200 requests reached both targets; sample 7 primary / 5 secondary |
| Developer user key | HTTP 200 with model text |
| MCP | Initialized; discovered 3 tools; invoked `microsoft_docs_search` successfully |
| Optional organization guardrail | HTTP 446; explicitly attached owned policy denied its unique marker |

Actual helper output, with the configured model replaced by a placeholder:

```text
fallback: HTTP 200; model=<configured-model>; cache=DISABLED; target=config.targets[0]
fallback: default.contains denied probe (HTTP 446)
fallback: panw-prisma-airs.intercept denied probe (HTTP 446)
fallback: organization default.contains denied probe (HTTP 446)
MCP initialized; 3 tools on the first page.
MCP tool invocation succeeded.
```

During preceding controlled exercises on the same project:

- Replaced only the owned primary integration key with an invalid value, set retries to zero, and included 401 in fallback codes. The request succeeded with HTTP 200 on `config.targets[1]`. Restored the key and routing settings afterward.
- Lowered the application's request limit to 1/minute. One request returned 200, followed by two 429 responses carrying a rate-limit error. Restored the threshold.
- Lowered the token budget to 2 below accumulated usage. A request returned HTTP 412 carrying a usage-limit error. Restored the budget.

These exercises establish failover and actual policy enforcement. A small weighted sample does not establish an exact long-run ratio. Both connections used the same backend/model, so the run does not establish resilience across independent services. Retry settings were stored and updated; the run did not measure retry attempt counts independently.

## Cleanup

```text
$ terraform destroy
Destroy complete! Resources: 26 destroyed.
$ terraform state list
# No managed resources remain.
```

Independent API queries verified the owned configs, guardrails, keys, policies, integrations, providers, secret reference, and MCP objects were absent; their bindings' parents were absent. Full Runtime profile inventories showed no owned revision. The hybrid registration was archived. The preexisting provider remained active. Earlier exploratory fixtures were also destroyed and audited.

## Limits and deployment observations

- All optional resource types completed management lifecycles. External-secret retrieval was not tested; the reference remained unbound and the real upstream keys came from environment variables.
- Hybrid registration was tested through archival cleanup. No new gateway infrastructure was installed or connected.
- The unreferenced organization policy did not deny its marker on the tested deployment. Explicit attachment to the owned configs succeeded. Automatic baseline enforcement in other workspaces remains unverified.
- Policies match caller-supplied application metadata; this is not an authenticated application identity boundary.
- A provider family being listed in the management catalog does not guarantee runtime support. A TypeSafe connection was rejected by the tested chat runtime; the successful fixture used its supported OpenAI-compatible family.
- The run used an already configured tenant AIRS plugin. It did not provision or change shared plugin settings.
