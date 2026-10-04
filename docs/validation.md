# Recorded live validation

The [Gateway catalog lesson](../examples/ai-gateway/provider-catalog/validation.md) uses Registry provider **0.11.0**. Its discovery evidence and model-request results are recorded separately from the four product roots below.

## Current release: provider 0.10.0 (four product roots)

The [2026-10-04 live runs](live-runs/provider-0.10.0.md) and [exact source receipts](live-runs/provider-0.10.0-receipts.json) cover the current examples. The signed Registry provider is pinned to 0.10.0. All 26 resources and 27 data sources appear in the [schema-checked coverage table](resource-coverage.md); shared-rule adoption and tenant onboarding remain protected, optional lessons.

Local validation passes four locked Terraform roots, **17 mock Terraform feature tests**, and **13 Python helper tests**, without tenant access. Fresh live runs cover all four products and both Gateway workspace paths, followed by independent cleanup queries. See the current release report for precise operation limits.

## Historical provider 0.9.0 evidence

All four products were exercised against the vulture tenant on 2026-10-03 using Terraform 1.16.4 and the signed Registry provider `cdot65/prisma-airs` 0.9.0. Management credentials were supplied through `PANW_MGMT_*` environment variables. Upstream credentials for the expanded Gateway application came from an owner-provided private file and were passed as sensitive Terraform environment variables.

The product READMEs are getting-started guides. This document describes evidence and its limits; it is not a substitute for their prerequisites.

## Historical configuration evidence

| Project | Created | Update and convergence | Cleanup |
| --- | --- | --- | --- |
| Runtime Security | Profile and topic | Annotation and topic action; empty plan after refresh | Full inventories contain neither owned name |
| Red Teaming | Target and prompt set | Descriptions; empty plan after refresh | Target absent; prompt set inactive |
| Gateway | 26 resources; all 15 Gateway resource types plus a Runtime profile | Descriptions, retry attempts, weighting, request/token thresholds; empty plan after refresh | Owned resources absent or archived; empty state; existing provider active |
| Supply Chain Security | Model group with discovered rule IDs | Description; empty plan after refresh | Group tombstoned |

[validation-receipts.json](validation-receipts.json) identifies tested HCL using SHA-256 after normalizing trailing whitespace. The three other products retain their original configuration receipts. The original two-resource Gateway receipt and transcript are historical; the current expanded application has its own receipt and [run evidence](live-runs/ai-gateway-expanded.md).

The subsequent readability cleanup changes formatting and comments across the 16 example HCL files. [readability-receipt.json](readability-receipt.json) records their current source hashes and matching configuration-token fingerprints against merged revision `d24159b`. The original live-tested hashes and run times remain preserved above; this cleanup used local parsing and validation without another live lifecycle.

Each lifecycle included a saved creation plan, apply, unchanged plan returning exit code 0, saved update plan, apply, refresh-only apply, another unchanged plan returning 0, destroy, empty-state check, and independent product API cleanup queries. Runtime profile revision IDs may change; Gateway configuration IDs remain stable while version IDs advance.

## Request evidence and boundaries

The expanded Gateway run additionally demonstrated real inference, marker denial, AIRS injection blocking, fallback after a controlled primary credential failure, both weighted targets, conditional target selection, cache MISS/HIT, request-limit enforcement, token-budget enforcement, a developer-key request, MCP discovery/invocation, and an explicitly attached organization guardrail. See the [recorded request results](live-runs/ai-gateway-expanded.md) for the test conditions and limitations.

Secret-reference CRUD does not establish retrieval from an external secret store. Hybrid deployment registration does not install or prove connectivity of a new deployment. Both live routing connections used the same backend/model. Caller-supplied application metadata is not an authenticated identity boundary. Automatic organization-policy enforcement in other workspaces was not established.

The other product runs establish configuration lifecycles. They do not establish Runtime detection quality, Red Team attack execution, model scanning, or skill analysis. Those operations require separate application inputs and execution workflows.

Public excerpts omit progress details and replace identifiers, endpoints, and model names with labeled placeholders where necessary. No credentials, state, or saved plans are committed. These are recorded results, not continuously monitored guarantees.

## Local validation

`python3 scripts/validate.py` checks formatting, locked provider installation, schema validation, mock feature tests for all four projects, release coverage, and Python helper tests without tenant access or remote writes. The optional CI matrix performs the per-project Terraform checks; it does not run the coverage gate or Python test suite and does not reproduce live lifecycle evidence.

## Post-review MCP regression check

Independent review of head `a15fef5` identified per-line JSON parsing in SSE responses. The decoder now joins data fields within each complete event before parsing JSON. Six offline regression tests cover multiline initialization/discovery/invocation, SSE line endings and BOM, event boundaries, errors, plain JSON compatibility, and incomplete/malformed events. Together with the existing helper tests, 13 tests pass. The [SSE parsing standard](https://html.spec.whatwg.org/multipage/server-sent-events.html#parsing-an-event-stream) defines the event framing.

This correction changes Python response parsing only. Terraform configuration and live source-hash receipts remain unchanged; regression validation requires no tenant credentials or live API writes.

## Historical Skill Scanning preview

The Supply Chain extension was separately validated against a local snapshot of ongoing provider Skill Scanning work using published Go SDK 0.7.0. It created a model group and synthetic fingerprint override, replaced the override after a reason change, refreshed with an empty plan, and destroyed both fixtures. Independent checks confirmed the group tombstone and absence of the synthetic fingerprint override.

That development-override run did not validate a released provider binary. Provider 0.10.0 has since shipped, and the current extension is pinned and live-tested against that Registry package; the fresh receipt above supersedes the earlier release dependency. Existing tenant instances and shared rule policy were not modified. Instance discovery returned HTTP 403 and is not required by the example.
