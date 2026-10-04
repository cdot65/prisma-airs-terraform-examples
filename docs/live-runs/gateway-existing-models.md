# Real requests through existing Gateway connections

Recorded on 2026-10-04 with Terraform 1.16.4, the catalog-capable development provider, and `airs` CLI 0.1.2. These are actual responses, not mock fixtures. Completion identifiers and upstream documentation URLs are sanitized; response fields, token counts, model IDs, assistant text, and errors are retained.

## What this run owns

The CLI discovered existing connections in the authorized test tenant using `airs cli aigateway integrations list --output json` and `airs cli aigateway providers list --workspace <existing-workspace-uuid> --output json`. Its default tenant was left unchanged by using an isolated tenant registry. The available connections included a standard OpenAI integration, three Vertex AI integrations, and one Bedrock integration; no direct Anthropic integration was configured.

The [exact Terraform source](gateway-existing-models-source.tf) reads workspace providers and creates only temporary routing configs and service application keys. It does not create or modify shared integrations, bindings, providers, workspaces, or upstream credentials. This is supplemental inference evidence, **not** a live apply of the catalog lesson's ten-resource project, which creates new OpenAI and direct Anthropic integrations. Configured upstream credentials are masked in the CLI and cannot be copied into new integrations.

## OpenAI GPT

An existing standard OpenAI connection, rather than an OpenAI-compatible custom host, served this request. A temporary application's saved config selected the connection and `gpt-4.1`, with retries disabled and config overrides disallowed.

The recorded command used a private request file and isolated runtime configuration containing the temporary application key and deployment URL:

```bash
airs cli aigateway inference chat --file request.json --timeout 60000 --output json
```

The request file contained this actual body, with only the workspace-provider slug sanitized:

```json
{
  "model": "@<existing-openai-provider-slug>/gpt-4.1",
  "messages": [{"role": "user", "content": "Reply with one short greeting."}],
  "max_tokens": 32
}
```

The command exited 0 and returned:

```json
{
  "id": "<chat-completion-id>",
  "choices": [
    {
      "finish_reason": "stop",
      "index": 0,
      "message": {
        "content": "Hello!",
        "role": "assistant",
        "refusal": null,
        "annotations": []
      },
      "logprobs": null
    }
  ],
  "created": 1791128994,
  "model": "gpt-4.1-2025-04-14",
  "system_fingerprint": "<system-fingerprint>",
  "object": "chat.completion",
  "usage": {
    "completion_tokens": 2,
    "prompt_tokens": 13,
    "total_tokens": 15,
    "completion_tokens_details": {
      "reasoning_tokens": 0,
      "accepted_prediction_tokens": 0,
      "rejected_prediction_tokens": 0,
      "audio_tokens": 0
    },
    "prompt_tokens_details": {
      "cached_tokens": 0,
      "audio_tokens": 0
    }
  },
  "service_tier": "default"
}
```

The returned model snapshot is `gpt-4.1-2025-04-14`, with 13 prompt tokens and 2 completion tokens. This proves an existing OpenAI route accepted real traffic; catalog lookup alone does not prove model access.

## Claude Opus: actual upstream failures

All three existing Vertex AI connections were tried with model `claude-opus-4-6`, one request per connection. Each CLI request exited 1 with this actual error:

```text
✗ Error: AISEC_CLIENT_SIDE_ERROR:vertex-ai error: Request had invalid authentication credentials. Expected OAuth 2 access token, login cookie or other valid authentication credential. See <upstream-docs-url>
    HTTP 401
    Re-run with --debug to capture redacted API diagnostics.
```

The existing Bedrock connection was tried with model `global.anthropic.claude-opus-4-6-v1`. That CLI request also exited 1:

```text
✗ Error: AISEC_CLIENT_SIDE_ERROR:bedrock error: The security token included in the request is invalid.
    HTTP 403
    Re-run with --debug to capture redacted API diagnostics.
```

These errors identify an upstream authentication prerequisite; they do not demonstrate a successful Claude response or prove that model entitlement is present. Repair the relevant cloud connection's credentials, or configure the lesson's direct Anthropic integration with a valid Anthropic API credential, before expecting successful Claude inference. No shared credential was changed during these checks.

## Cleanup

The first probe created four objects (two configs and two keys); each of the three follow-up probes created two objects. Each actual destroy reported the matching count, and all four probe states were verified empty. Independent CLI GET requests then confirmed all ten config/key UUIDs absent (HTTP 404). The [receipt](gateway-existing-models-receipt.json) records source/output hashes, request outcomes, and cleanup results. Private state, keys, upstream settings, and tenant/resource UUIDs are excluded from this repository.
