# Recorded live validation

All four products were exercised against the vulture tenant on 2026-10-03 using Terraform 1.16.4 and the signed Registry provider `cdot65/prisma-airs` 0.9.0. Management credentials were supplied through `PANW_MGMT_*` environment variables. Upstream credentials for the expanded Gateway application came from an owner-provided private file and were passed as sensitive Terraform environment variables.

The product READMEs are getting-started guides. This document describes evidence and its limits; it is not a substitute for their prerequisites.

## Current configuration evidence

| Project | Created | Update and convergence | Cleanup |
| --- | --- | --- | --- |
| Runtime Security | Profile and topic | Annotation and topic action; empty plan after refresh | Full inventories contain neither owned name |
| Red Teaming | Target and prompt set | Descriptions; empty plan after refresh | Target absent; prompt set inactive |
| Gateway | 26 resources; all 15 Gateway resource types plus a Runtime profile | Descriptions, retry attempts, weighting, request/token thresholds; empty plan after refresh | Owned resources absent or archived; empty state; existing provider active |
| Supply Chain Security | Model group with discovered rule IDs | Description; empty plan after refresh | Group tombstoned |

[validation-receipts.json](validation-receipts.json) identifies tested HCL using SHA-256 after normalizing trailing whitespace. The three other products retain their original configuration receipts. The original two-resource Gateway receipt and transcript are historical; the current expanded application has its own receipt and [run evidence](live-runs/ai-gateway-expanded.md).

Each lifecycle included a saved creation plan, apply, unchanged plan returning exit code 0, saved update plan, apply, refresh-only apply, another unchanged plan returning 0, destroy, empty-state check, and independent product API cleanup queries. Runtime profile revision IDs may change; Gateway configuration IDs remain stable while version IDs advance.

## Request evidence and boundaries

The expanded Gateway run additionally demonstrated real inference, marker denial, AIRS injection blocking, fallback after a controlled primary credential failure, both weighted targets, conditional target selection, cache MISS/HIT, request-limit enforcement, token-budget enforcement, a developer-key request, MCP discovery/invocation, and an explicitly attached organization guardrail. See the [recorded request results](live-runs/ai-gateway-expanded.md) for the test conditions and limitations.

Secret-reference CRUD does not establish retrieval from an external secret store. Hybrid deployment registration does not install or prove connectivity of a new deployment. Both live routing connections used the same backend/model. Caller-supplied application metadata is not an authenticated identity boundary. Automatic organization-policy enforcement in other workspaces was not established.

The other product runs establish configuration lifecycles. They do not establish Runtime detection quality, Red Team attack execution, model scanning, or skill analysis. Those operations require separate application inputs and execution workflows.

Public excerpts omit progress details and replace identifiers, endpoints, and model names with labeled placeholders where necessary. No credentials, state, or saved plans are committed. These are recorded results, not continuously monitored guarantees.

## Local validation

`python3 scripts/validate.py` checks formatting, locked provider installation, schema validation for all four projects, and request-helper tests without tenant access or remote writes. The optional CI template performs these checks; it does not reproduce live lifecycle evidence.

## Skill Scanning release dependency

The Supply Chain extension was separately validated against a local snapshot of ongoing provider Skill Scanning work using published Go SDK 0.7.0. It created a model group and synthetic fingerprint override, replaced the override after a reason change, refreshed with an empty plan, and destroyed both fixtures. Independent checks confirmed the group tombstone and absence of the synthetic fingerprint override.

That development-override run does not validate a released provider binary. The extension remains deferred until an upstream provider release is published, its actual version is pinned, and the final configuration passes its lifecycle with the Registry package. Existing tenant instances and shared rule policy were not modified. Instance discovery returned HTTP 403 and is not required by the example.
