# Provider 0.12.0 — adapters and adoption

Provider **0.12.0** adds adapter ownership and discovery. Independent Codex review scored Standards **9.3/10** and Spec **9.4/10** after fixing the target write-safety findings. The signed Registry install and released example lifecycle are recorded separately; existing product-root pins and historical receipts remain reproducible. The current provider exposes **27 resources and 30 data sources**.

| New Terraform type | Getting-started project |
| --- | --- |
| Resource `prisma-airs_red_team_adapter` | [Adapter script and variable ownership](../examples/ai-red-teaming/adapters/main.tf) |
| Data source `prisma-airs_red_team_adapters` | [Exact name-to-UUID discovery](../examples/ai-red-teaming/adapters/main.tf) |
| Data source `prisma-airs_red_team_adapter` | [Read-only adapter configuration](../examples/ai-red-teaming/adapters/main.tf) |

The same project demonstrates `prisma-airs_red_team_target.adapter`, explicit execution opt-in, null response mode, target dependency ordering, and cleanup. Its [getting-started guide](../examples/ai-red-teaming/adapters/README.md) includes adoption instructions and links [real sanitized released-provider output](../examples/ai-red-teaming/adapters/released-live-run.md). A separate disposable fixture proved redacted-secret retention; this connectivity example uses a deterministic text reply rather than claiming a model-security assessment.

Provider adoption fixes also recover usable endpoint-target payloads and OAuth templates, permit safe no-op configuration without unavailable secrets, and block incomplete writes. Runtime preserves observed empty toxic-content/category representations, and Gateway import supports bare native nulls with real drift detection. See the provider's [verification report](https://cdot65.github.io/terraform-provider-prisma-airs/development/adoption-fidelity-verification/) in the production documentation.

Check the pinned Registry project without tenant access:

```bash
python3 scripts/validate-adapters.py
python3 scripts/check_docs.py
```

For provider development, use `python3 scripts/validate-adapters.py --provider-dir /path/to/provider-checkout` to validate against a local build. The parent project validation remains separate so its released provider locks and evidence stay reproducible.
