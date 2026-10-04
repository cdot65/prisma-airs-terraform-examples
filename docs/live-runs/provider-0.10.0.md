# Provider 0.10.0 live run

These runs used the signed Registry provider `cdot65/prisma-airs` **0.10.0**, Terraform **1.16.4**, and an authorized test tenant on **2026-10-04**. Management and upstream credentials were supplied through environment variables. This is recorded evidence; the [product guides](../../README.md#examples) explain how to get started.

Tenant/resource identifiers, endpoints, and returned model names are sanitized. No credentials, saved plans, state, or raw API responses are published. [Machine-readable receipts](provider-0.10.0-receipts.json) record exact SHA-256 hashes of every tested root's `.tf` files, update actions, enabled feature selectors, read data-source families, and runtime results.

## Configuration results

| Project / variant | Created resources | Update | Convergence and cleanup |
| --- | ---: | --- | --- |
| Runtime Security | 3: topic, security profile, scanning API key | Topic action and profile annotation | Empty plans before/after refresh; complete profile/topic/key/app inventories contain no fixtures |
| Red Teaming | 2: target and prompt set | Both descriptions | Empty plans; target absent and prompt set inactive |
| Supply Chain | 2: model group and synthetic Skill trust override | Group annotation; override replacement | Empty plans; group tombstoned and fingerprint absent |
| Gateway: owned workspace | 20, including workspace and its managed IAM scope lifecycle | Workspace/integration descriptions and fallback retry | Empty plans; workspace positively confirmed archived, owned scope absent; no managed state |
| Gateway: existing workspace, full platform | 26, covering the 15 other Gateway resource types plus a Runtime profile | Integration descriptions and fallback retry | Empty plans; resources absent/archived; original connection remains active |

Every variant ran `init -lockfile=readonly`, `validate`, a saved create plan/apply, an unchanged plan returning **0**, a saved update plan/apply, refresh-only apply, another unchanged plan returning **0**, and a saved destroy plan/apply. No managed resources remain in any state. Independent API reads verified cleanup separately from Terraform's empty-state checks.

Archiving the owned workspace makes some child reads return **403**. The audit records those reads as inaccessible after positively matching the workspace UUID and `status = archived` in the admin archived list and confirming the owned IAM scope is absent; it does not interpret 403 as proof that an individual child is absent. The existing-workspace run allows independent child checks. Model groups and some Gateway registrations retain archived/tombstoned records.

## Read-only discovery

Gateway exercised the new singular workspace lookup, workspace inventory, and all 13 other inventory families. Runtime exercised DLP and deployment-profile discovery and selected one uniquely named deployment profile for its disposable key. Skill Scanning exercised catalog/effective rule reads, filtered override lookup, scan history and nullable statistics, plus existing scan, vulnerability, attack-chain, and fingerprint lookups. No scan was started or deleted.

## Gateway request results

The existing-workspace run used two provider-family connections to the same backend/model. Each command ran after Terraform apply:

```text
python3 demo.py --mode fallback
fallback: HTTP 200; model=<SANITIZED_MODEL>; cache=DISABLED; target=config.targets[0]

python3 demo.py --mode fallback --deny
fallback: default.contains denied probe (HTTP 446)

python3 demo.py --mode balanced --repeat 4
four HTTP 200 responses; both config.targets[0] and config.targets[1] observed

python3 demo.py --mode conditional --tier standard
HTTP 200; target=config.targets[0]
python3 demo.py --mode conditional --tier premium
HTTP 200; target=config.targets[1]

python3 demo.py --mode cached --repeat 2
HTTP 200; cache=MISS
HTTP 200; cache=HIT

python3 demo.py --mode fallback --attack
fallback: panw-prisma-airs.intercept denied probe (HTTP 446)

python3 demo.py --mode fallback --org-deny
fallback: organization default.contains denied probe (HTTP 446)
```

The owned-workspace run separately recorded a successful inference response (**200**) and deterministic denial (**446**). These results establish request behavior for the tested deployment. They do not establish resilience between independent services or automatic organization enforcement in unrelated workspaces.

## Unexercised operations

Shared Skill rule adoption and tenant onboarding were checked with schema validation and mock plans, without changing shared policy or registration. Existing customer-app adoption remains import-only and was not applied to an external app. Instance reads were not exercised in this release run; entitlement and permissions remain prerequisites.

Secret-reference and hybrid-registration lifecycles passed, without demonstrating external-secret retrieval or installing a new gateway. MCP registration/binding/server CRUD passed; fresh MCP tool discovery/invocation was not repeated. [Historical Gateway evidence](ai-gateway-expanded.md) records those earlier request exercises, developer-key traffic, controlled failover, and limit enforcement under provider 0.9.0. Their results are not relabeled as fresh 0.10.0 tests.

The public repository's [coverage table](../resource-coverage.md) proves declared schema coverage of all 26 resources and 27 data sources. Declared or mock-tested coverage does not imply live writes for every type.
