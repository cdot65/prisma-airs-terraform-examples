# Catalog lesson checks

## Registry provider 0.11.0

Both catalog roots install the signed Registry provider using `terraform init` and pass schema validation. The two-service root passes all three mocked Terraform tests without API access. Committed lock files record the publisher-signed package checksums.

The read-only discovery root was also applied live with the released binary. Its [actual CLI transcript](../../../docs/live-runs/gateway-provider-catalog-release.txt) and [receipt](../../../docs/live-runs/gateway-provider-catalog-release-receipt.json) record the exact current source, provider version/binary hash, and results: 81 catalog entries, 79 active lookup pairs, distinct OpenAI/Anthropic family UUIDs, zero managed resources, unchanged-plan exit 0, and empty state after cleanup. Identifiers are sanitized; counts and Terraform text are retained.

## Earlier development and inference checks

Validated on 2026-10-04 against the catalog-capable development provider built from Go SDK 0.8.1, using Terraform 1.16.4. This historical evidence used a development binary. The current example pins Registry provider 0.11.0; release installation and checks are recorded separately below.

The complete configuration passes `terraform validate` and three mocked Terraform tests: both provider UUIDs are read from their correct slugs, GPT and Claude Opus select separate model routes/application keys, and missing credentials or model selections are rejected. The provider's Go tests cover the read-only catalog route, refresh after a provider becomes inactive, duplicate IDs/slugs, empty identities, malformed/failed responses, empty catalogs, and exclusion of unexpected fields from state.

The read-only [archived discovery configuration](../../../docs/live-runs/gateway-provider-catalog-development-source.tf) was actually applied against the authorized test tenant. The [sanitized CLI transcript](../../../docs/live-runs/gateway-provider-catalog.txt) contains real apply/output/plan/destroy results, and its [receipt](../../../docs/live-runs/gateway-provider-catalog-receipt.json) records the exact source SHA-256 and provider build.

`terraform output -no-color` returned:

```text
catalog_counts = {
  "active" = 79
  "returned" = 81
}
provider_family_ids = {
  "anthropic" = "<anthropic-provider-family-uuid>"
  "open-ai" = "<openai-provider-family-uuid>"
}
```

The unchanged normal plan exited 0. Cleanup left zero state entries. UUID values and local paths are replaced with labeled placeholders; the output structure, counts, and recorded timings are unchanged. Mock test results remain separate from this live transcript.

The catalog run read data and recorded outputs only. It created no model connection, workspace binding, application key, or routing object.

A separate [CLI-backed inference run](../../../docs/live-runs/gateway-existing-models.md) reused existing workspace providers and applied only temporary routing configs and service application keys. The standard OpenAI connection returned `gpt-4.1-2025-04-14` with assistant text `Hello!` (13 prompt tokens, 2 completion tokens). Three Vertex AI requests for `claude-opus-4-6` failed with HTTP 401 upstream authentication errors; one Bedrock request for `global.anthropic.claude-opus-4-6-v1` failed with HTTP 403 and an invalid security token. No direct Anthropic integration was available, so successful Claude inference remains unverified. All ten temporary objects across four probes were destroyed; every probe state was empty afterward. The [exact source](../../../docs/live-runs/gateway-existing-models-source.tf) and [receipt](../../../docs/live-runs/gateway-existing-models-receipt.json) distinguish this evidence from the catalog run.

The ten-resource owned-integration project was validated offline, not applied live. Existing upstream keys are masked in the CLI and cannot be retrieved for creating new integrations. Neither catalog discovery nor an upstream authentication error proves model entitlement. Run the guide with valid upstream API credentials and models enabled in your own environment.

The four released product roots retain their provider 0.10.0 validation and evidence. Check the catalog lesson against its pinned Registry provider:

```bash
python3 scripts/validate-catalog.py
```

That command strips tenant/application environment variables and uses mocked Terraform reads and resources; it makes no API calls. Run it from the repository root. For provider development, optionally pass `--provider-dir /absolute/path/to/terraform-provider-prisma-airs` to use a local build.
