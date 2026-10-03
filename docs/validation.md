# Live validation

All four public projects were run against the **vulture** tenant on **2026-10-03**, using Terraform **1.16.4** and the signed, directly installed Registry provider **cdot65/prisma-airs 0.9.0**. Credentials came from the registered AIRS CLI tenant JSON and were supplied through the three shared `PANW_MGMT_*` environment variables. No credential file is part of the repository.

For each exact HCL project we:

1. Installed the provider from the Registry and validated the configuration.
2. Reviewed and applied a saved creation plan with a unique resource prefix.
3. Verified an unchanged plan with `terraform plan -detailed-exitcode` returning `0`.
4. Changed configured inputs, verified the expected update actions, and applied the saved update plan.
5. Checked stable resource identities, allowing Runtime profile revision UUIDs to change.
6. Applied refresh-only state updates and verified another unchanged plan returning `0`.
7. Destroyed the owned resources and verified no managed resources remained in state.
8. Independently queried the product APIs to establish absence or the API's retained deletion state.

## Results

| Project | Create | Update | Post-update plan | Independent cleanup result |
| --- | --- | --- | --- | --- |
| Runtime Security | 2 resources | Topic annotation and profile topic action | Empty | Complete profile/topic inventories contain neither owned name |
| Red Teaming | 2 resources | Target and prompt-set descriptions | Empty | Target GET 404; prompt set `active = false` |
| Gateway | 2 resources | Retry attempts 1 → 2; rate threshold 100 → 120 | Empty | Config/rate-policy GETs 404; existing provider remains active |
| Supply Chain Security | 1 resource; rule discovery | Model-group description | Empty | Group `is_tombstone = true` |

The existing Red Team target remained active. The Runtime profile changed from revision 1 to revision 2. The Gateway routing ID stayed stable while its version UUID changed. Model Security retains a tombstoned record and can still show `state = ACTIVE`; that field alone does not prove the group is active.

Each README contains actual console summary lines from its run, with progress lines and identifiers omitted. These are explicitly labeled sanitized excerpts. [validation-receipts.json](validation-receipts.json) records the run times and hashes of the tested HCL files (normalizing trailing whitespace) without credentials, resource identifiers, or tenant IDs. These are recorded validation results, not a continuously monitored service guarantee.

## Validation boundary

The tests establish declarative **configuration lifecycles**. They do not establish Runtime detection quality, Red Team attack execution, inference connectivity, actual Gateway rate enforcement, model scanning, or skill analysis. Those operations need separate application inputs and execution workflows.

The local validation command and optional CI workflow template check formatting, installation and schema validation without tenant access. They do not reproduce the live lifecycle evidence or mutate the environment.

## Skill Scanning release dependency

The Supply Chain extension was separately validated against a local snapshot of the provider's ongoing Skill Scanning implementation using published Go SDK **0.7.0**. It successfully created a model group and synthetic fingerprint override, replaced the override when its reason changed, refreshed with an empty plan, and destroyed both fixtures. Independent checks confirmed the group's tombstone and the absence of the synthetic fingerprint from the override inventory.

That candidate uses a development override and is **not evidence of a released provider binary**. The extension will be included in the public project after the upstream provider release is published, the project and lock file pin its actual version, and the exact final configuration passes the same lifecycle using the Registry package. Existing tenant instances and shared rule policy were not modified. Instance discovery returned HTTP 403 on vulture and is not required by the example.
