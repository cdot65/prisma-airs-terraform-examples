# Discover OpenAI and Claude provider IDs

Build two model connections in an existing Gateway workspace. Terraform reads the provider catalog and resolves UUIDs from `open-ai` and `anthropic`; you supply API credentials and model choices, not provider-family UUIDs. Each service gets its own workspace provider, routing configuration, and Gateway application key.

## Before you start

**This example requires the new catalog-capable provider build, pending release. Registry provider 0.10.0 does not support this data source.** The [released expanded project](../README.md) remains available for 0.10.0; this focused example demonstrates the replacement discovery workflow.

You need Terraform 1.11+, the [management environment variables](../../../README.md#get-started), an existing Gateway workspace with an inference deployment, and OpenAI and Anthropic API credentials. ChatGPT subscription access does not supply an OpenAI API credential. The sample uses the API model IDs `gpt-4.1` and `claude-opus-4-6`; choose alternatives if your account or Gateway has different models enabled. See [OpenAI's model reference](https://developers.openai.com/api/docs/models/gpt-4.1) and [Claude model IDs](https://platform.claude.com/docs/en/about-claude/models/model-ids-and-versions).

For this development setup, install Go 1.25.6+ and `make`, then build the catalog-capable provider branch:

```bash
git clone --branch feat/gateway-provider-catalog https://github.com/cdot65/terraform-provider-prisma-airs.git
cd terraform-provider-prisma-airs
make build
```

Create `dev.tfrc` outside this example, replacing the path with the absolute directory containing the binary:

```hcl
# Development install: Load the catalog-capable provider binary.
provider_installation {
  dev_overrides {
    "cdot65/prisma-airs" = "/absolute/path/to/terraform-provider-prisma-airs"
  }
  direct {}
}
```

Select it in the shell used for Terraform:

```bash
export TF_CLI_CONFIG_FILE=/absolute/path/to/dev.tfrc
```

Until release, skip `terraform init`: the development override loads the local binary directly, bypassing Registry version selection. Once the feature is published, pin its exact version, remove the override, and initialize normally. The current constraint excludes Registry 0.10.0; it does not claim a later release already exists.

## See real discovery output

With the development override and management environment variables selected, run the read-only configuration before creating connections:

```bash
terraform -chdir=discovery apply
terraform -chdir=discovery output -no-color
```

This uses [discovery/main.tf](discovery/main.tf) and requires no upstream API keys. The following is actual Terraform output captured from the test tenant on 2026-10-04; only UUID values are replaced with labeled placeholders:

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

The recorded apply reported:

```text
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

These UUIDs came from the live catalog, not mock fixtures. Terraform stored read-only data and outputs without creating upstream integrations. Use `data.prisma-airs_gateway_ai_providers.catalog.ids_by_slug["open-ai"]` or `["anthropic"]` directly when creating your own connections, as the parent configuration does.

The [full CLI transcript](../../../docs/live-runs/gateway-provider-catalog.txt) includes the actual apply, output, unchanged plan, and cleanup; its [receipt](../../../docs/live-runs/gateway-provider-catalog-receipt.json) records the tested source hash and provider build. Local paths and UUIDs are sanitized. Clean up this read-only state's outputs when finished:

```bash
terraform -chdir=discovery destroy
```

## Configure both models

From this directory:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set your existing `workspace_id` and an unused `name_prefix`. Keep the sample `models` map or choose API model IDs enabled on your Gateway connections. No integration or provider-family UUID is an input.

Load `TF_VAR_upstream_api_keys` through your credential store with this JSON shape:

```json
{"open-ai": "<openai-api-key>", "anthropic": "<anthropic-api-key>"}
```

Keep actual keys out of input files and terminal output. The keys are upstream API credentials; Terraform's management OAuth and the Gateway application keys serve different purposes.

## Apply

```bash
terraform validate
terraform plan -out=create.tfplan
terraform apply create.tfplan
terraform output routes
```

Terraform creates **10 resources**: two integrations, two workspace bindings, two workspace providers, two routing configs, and two application keys. It reads the provider catalog without owning any catalog entry or the existing workspace.

The exact catalog slugs are `open-ai` and `anthropic`. `ids_by_slug` is a computed `map(string)` containing active catalog entries. A missing/inactive slug fails lookup; duplicate identities fail discovery. `routes` shows the resolved provider-family ID separately from the newly created integration, workspace provider, and config IDs. Use those references directly in other Terraform configuration or module inputs.

Protect state and saved plans: the sensitive `application_keys` output and upstream credentials are stored there. Catalog discovery does not enable models or establish inference connectivity. Enable/register your selected models in Gateway if your environment requires it.

## Send a request to each service

Set your inference base URL, including `/v1`:

```bash
export PANW_AI_GW_INFERENCE_ENDPOINT="https://YOUR-GATEWAY/v1"
```

Call the OpenAI GPT route:

```bash
export PANW_AI_GW_APP_KEY="$(terraform output -json application_keys | python3 -c 'import json,sys; print(json.load(sys.stdin)["open-ai"])')"
curl --fail-with-body --silent --show-error \
  "$PANW_AI_GW_INFERENCE_ENDPOINT/chat/completions" \
  -H "x-portkey-api-key: $PANW_AI_GW_APP_KEY" \
  -H 'Content-Type: application/json' \
  --data '{"model":"gpt-4.1","messages":[{"role":"user","content":"Reply with one short greeting."}],"max_tokens":32}'
unset PANW_AI_GW_APP_KEY
```

Call the Anthropic Claude Opus route:

```bash
export PANW_AI_GW_APP_KEY="$(terraform output -json application_keys | python3 -c 'import json,sys; print(json.load(sys.stdin)["anthropic"])')"
curl --fail-with-body --silent --show-error \
  "$PANW_AI_GW_INFERENCE_ENDPOINT/chat/completions" \
  -H "x-portkey-api-key: $PANW_AI_GW_APP_KEY" \
  -H 'Content-Type: application/json' \
  --data '{"model":"claude-opus-4-6","messages":[{"role":"user","content":"Reply with one short greeting."}],"max_tokens":32}'
unset PANW_AI_GW_APP_KEY
```

If you change `models`, update the request model ID to match. Each key selects its saved model route and disallows config overrides. Expect a successful HTTP response with assistant text; confirm the upstream/model in the response or Gateway logs. Missing models, billing/access problems, authentication failures, and upstream errors are failures, not successful demonstrations. These commands make billable model calls when run.

## A real model response

A supplemental run used `airs cli aigateway` to discover existing connections and Terraform to create temporary model routes and application keys. Its standard OpenAI connection returned this actual response excerpt:

```json
{
  "model": "gpt-4.1-2025-04-14",
  "choices": [{"message": {"content": "Hello!", "role": "assistant"}}],
  "usage": {"completion_tokens": 2, "prompt_tokens": 13, "total_tokens": 15}
}
```

This is an excerpt of [the full recorded response](../../../docs/live-runs/gateway-existing-models.md#openai-gpt), not a complete response schema or a mock. That run reused a configured OpenAI integration; it did not apply this lesson's ten-resource project that creates new upstream connections.

Claude Opus requests through the tenant's existing Vertex and Bedrock connections returned upstream authentication errors (HTTP 401 and 403). There was no direct Anthropic connection, so a successful Claude response is **not yet verified**. The [actual errors and cleanup results](../../../docs/live-runs/gateway-existing-models.md#claude-opus-actual-upstream-failures) show what happened. Your own valid Anthropic API credentials remain a prerequisite for the direct Claude route above.

## Change and clean up

Change a model in `models`, review a plan, and apply the route update. Use the same tenant and input values for cleanup:

```bash
terraform plan -destroy -out=cleanup.tfplan
terraform apply cleanup.tfplan
```

Cleanup removes the owned objects and disables the owned workspace bindings. The existing workspace and provider catalog remain external.

See [validation notes](validation.md) for the checks actually performed. The [expanded Gateway project](../README.md) covers AIRS guardrails, routing patterns, limits, and optional platform features.
