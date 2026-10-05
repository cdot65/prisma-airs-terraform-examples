# Prisma AIRS Terraform Examples

Configure Prisma AIRS with ready-to-run Terraform projects using the [Prisma AIRS provider](https://registry.terraform.io/providers/cdot65/prisma-airs/latest). Choose a product, supply your environment credentials, and follow its guide from your first plan through cleanup.

| Start here | What you build |
| --- | --- |
| [AI Runtime Security](examples/ai-runtime-security/README.md) | A confidential-information topic, application policy, optional scanning key, and import-only application |
| [AI Red Teaming](examples/ai-red-teaming/README.md) | An authenticated application target and custom prompt-set container |
| [AI Gateway](examples/ai-gateway/README.md) | Existing or owned workspace with dedicated IAM scope, model connections, four routing lessons, AIRS guardrails, application keys, request/token policies, and optional platform capabilities |
| [AI Supply Chain Security](examples/ai-supply-chain-security/README.md) | A Model Security group, Skill Scanning catalogs, synthetic trust, optional shared policy/onboarding, and existing scan discovery |
| [Forgejo CI/CD with Conjur](examples/cicd/forgejo-conjur/README.md) | Adopt existing configuration, retrieve credentials through workload JWT authentication, and manually apply an exact reviewed plan against locked MinIO state |
| [Native import → HCL tfvars → CI/CD](https://github.com/cdot65/prisma-airs-terraform-adoption-demo) | Follow one project from four existing unmanaged objects through generated HCL, import-only apply, typed tfvars, state migration, reviewed updates, and deliberate cleanup |

The [adapter walkthrough](examples/ai-red-teaming/adapters/README.md) uses Registry provider **0.12.0** for script and variable ownership, existing-broker activation, automatic UUID discovery, and adapter-backed targets. [0.12.0 coverage](docs/upcoming-provider-0.12.0.md) also explains the target import, Runtime policy, and Gateway null fixes.

The [OpenAI GPT and Claude Opus catalog lesson](examples/ai-gateway/provider-catalog/README.md) demonstrates automatic provider-family UUID discovery. It pins Registry provider **0.11.0**; the four product roots below retain their tested 0.10.0 compatibility pins.

Each directory is an independent Terraform root with its own state. Start with one product; you do not need to apply all four. The four product roots pin published provider **0.10.0** and require Terraform **1.11 or later**, before 2.0. Terraform 1.11 enables the Skill Scanning write-only authorization code; its input variable is ephemeral. [Release coverage](docs/resource-coverage.md) maps all 26 resources and 27 data sources to runnable configuration, including optional and import-only lessons.

For a newcomer adopting existing configuration, start with the standalone [native adoption demonstration](https://github.com/cdot65/prisma-airs-terraform-adoption-demo). It uses Terraform **1.16.4** and provider **0.12.0**, teaches native `import` blocks and `-generate-config-out`, and keeps editable settings in ordinary HCL tfvars. Its numbered guide includes real sanitized four-product results and Forgejo/Conjur handoff; it owns only four disposable fixtures, independently of the existing production state.

## Get started

Install Terraform and obtain a Prisma AIRS service account with access to your chosen product. Clone this repository:

```bash
git clone https://github.com/cdot65/prisma-airs-terraform-examples.git
cd prisma-airs-terraform-examples
```

Load these variables from your credential store into the shell that runs Terraform:

| Environment variable | Value |
| --- | --- |
| `PANW_MGMT_CLIENT_ID` | Service-account OAuth client ID |
| `PANW_MGMT_CLIENT_SECRET` | Service-account OAuth client secret |
| `PANW_MGMT_TSG_ID` | Tenant Service Group ID |

The provider uses these variables through its empty provider block. Terraform does not automatically load `.env` files. Product guides describe any additional application credentials, such as an upstream model key or target authentication headers. Keep those credentials in environment variables too.

For example, to create a Runtime Security policy:

```bash
cd examples/ai-runtime-security
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: choose a unique name_prefix.
terraform init
terraform plan -out=create.tfplan
terraform apply create.tfplan
terraform output
```

Read the [Runtime Security guide](examples/ai-runtime-security/README.md) for the policy's purpose, outputs, and next steps. For a different product, start from its guide and fill its own prerequisites before planning.

After exploring an example, remove its resources from the same directory with the same tenant credentials and inputs:

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

State and saved plans can contain secrets even when Terraform hides console output. They are excluded from Git; protect them locally or use an access-controlled encrypted remote backend. Do not change tenants while reusing the same state.

## Optional AIRS CLI credential helper

If your tenant is already registered with the AIRS CLI, Python 3 and the helper can load the linked management credentials into a child process:

```bash
airs cli tenant list
# Replace YOUR_TENANT with the registered name; run from the repository root.
python3 scripts/with-tenant.py YOUR_TENANT terraform -chdir=examples/ai-runtime-security plan
```

The helper reads `mgmtClientId`, `mgmtClientSecret`, and `mgmtTsgId` from the linked JSON, without switching the selected CLI tenant or printing credentials. It does not supply upstream model keys or target credentials. Normal Terraform commands remain the main workflow when your environment is already configured.

## Explore and contribute

Examples create their own named configuration and reference external application endpoints and integrations where documented. Gateway defaults to an existing workspace and can opt in to owning a new workspace and dedicated IAM scope. Gateway creates its upstream connections and bindings; its optional organization policy is organization-scoped and explicitly attached to the owned configurations. Read its [platform guide](examples/ai-gateway/platform.md) before enabling optional features. [Resource ownership](docs/adr/0001-example-resource-ownership.md) explains cleanup boundaries.

Terraform files use short `# Concept: purpose` comments at concept boundaries and multiline objects for nested configuration. Keep comments focused on dependencies and product behavior; variable descriptions explain individual inputs.

Run `python3 scripts/validate.py` to check formatting, Registry installation, provider schema validation, 17 mocked Terraform feature tests, complete release coverage, documentation links/evidence hashes, and request-helper tests without tenant credentials. An optional [GitHub Actions template](ci/README.md) runs the per-project Terraform checks in CI; run the full script for coverage and Python tests. Recorded live results and their limits are in [validation documentation](docs/validation.md); short sanitized output excerpts appear in the guides.

The CI/CD harness has 18 offline control tests and a locked provider schema check included in `scripts/validate.py`. Its [recorded cutover](examples/cicd/forgejo-conjur/live-run.md) captures real four-product adoption, state migration, and pipeline results. The [end-to-end lifecycle](examples/cicd/forgejo-conjur/e2e-live-run.md) also exercises real create/update/cleanup applies and review-gate refusals.

Check the catalog lesson separately with `python3 scripts/validate-catalog.py`. Its [validation notes](examples/ai-gateway/provider-catalog/validation.md) distinguish live catalog discovery, a real GPT request through an existing connection, Claude authentication failures, and mocked owned-integration checks.

[Upgrading existing examples](docs/upgrading.md) explains the new release pins and optional controls. Historical provider 0.9.0 run evidence remains explicitly labeled; fresh provider 0.10.0 runs are recorded separately.

See the [glossary](GLOSSARY.md) for product terminology. This community repository uses the MIT license.
