# Upcoming provider 0.12.0

This branch adds examples for the adapter/adoption candidate. Provider 0.12.0 is not released yet; the independent Claude Code review gate remains pending. Existing published projects and their historical receipts remain unchanged.

| New Terraform type | Getting-started project |
| --- | --- |
| Resource `prisma-airs_red_team_adapter` | [Adapter script and variable ownership](../examples/ai-red-teaming/adapters/main.tf) |
| Data source `prisma-airs_red_team_adapters` | [Exact name-to-UUID discovery](../examples/ai-red-teaming/adapters/main.tf) |
| Data source `prisma-airs_red_team_adapter` | [Read-only adapter configuration](../examples/ai-red-teaming/adapters/main.tf) |

The same project demonstrates `prisma-airs_red_team_target.adapter`, explicit execution opt-in, null response mode, target dependency ordering, and cleanup. Its [getting-started guide](../examples/ai-red-teaming/adapters/README.md) includes adoption instructions and links [real sanitized output](../examples/ai-red-teaming/adapters/live-run.md). A separate disposable fixture proved redacted-secret retention; this connectivity example uses a deterministic text reply rather than claiming a model-security assessment.

Provider adoption fixes also recover usable endpoint-target payloads and OAuth templates, permit safe no-op configuration without unavailable secrets, and block incomplete writes. Runtime preserves observed empty toxic-content/category representations, and Gateway import supports bare native nulls with real drift detection. See the candidate's [verification report](https://cdot65.github.io/terraform-provider-prisma-airs/development/adoption-fidelity-verification/) after its documentation is published.

Before release, check this project against a local candidate build:

```bash
python3 scripts/validate-adapters.py --provider-dir /path/to/provider-checkout
python3 scripts/check_docs.py
```

After publication, run `python3 scripts/validate-adapters.py` to install and validate the pinned Registry version. The parent project validation remains separate so its released provider locks and evidence stay reproducible.
