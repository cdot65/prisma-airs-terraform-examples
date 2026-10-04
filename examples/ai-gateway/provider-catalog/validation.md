# Catalog lesson checks

Validated on 2026-10-04 against the catalog-capable development provider built from Go SDK 0.8.1, using Terraform 1.16.4. This is **not** a Registry 0.10.0 run; the new data source is pending release.

The complete configuration passes `terraform validate` and three mocked Terraform tests: both provider UUIDs are read from their correct slugs, GPT and Claude Opus select separate model routes/application keys, and missing credentials or model selections are rejected. The provider's Go tests cover the read-only catalog route, refresh after a provider becomes inactive, duplicate IDs/slugs, empty identities, malformed/failed responses, empty catalogs, and exclusion of unexpected fields from state.

An actual Terraform data-source apply against the authorized test tenant returned this sanitized summary:

```text
catalog_entries: 81
active_lookup_entries: 79
openai_discovered: true
anthropic_discovered: true
distinct_uuid_matches: true
resource_writes: 0
```

The live check read the catalog and recorded data-source state only. Its test state was subsequently destroyed and verified empty. No model connection, workspace binding, application key, or routing object was created. Real OpenAI GPT and Claude Opus inference was **not** run: the available upstream credential is for a separate OpenAI-compatible service, not either first-party API. Model IDs in this lesson are documented examples, not live-verified tenant model availability. Run the guide's requests with your own enabled models and API credentials.

The four released product roots retain their provider 0.10.0 validation and evidence. Check this new development lesson separately:

```bash
python3 scripts/validate-catalog.py --provider-dir /absolute/path/to/terraform-provider-prisma-airs
```

That command strips tenant/application environment variables and uses mocked Terraform reads and resources; it makes no API calls. Run it from the repository root after building the local provider.
