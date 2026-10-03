# Prisma AIRS Terraform Examples

Configure Prisma AIRS with ready-to-run Terraform projects using the [Prisma AIRS provider](https://registry.terraform.io/providers/cdot65/prisma-airs/latest). Choose a product, supply your environment credentials, and follow its guide from your first plan through cleanup.

| Start here | What you build |
| --- | --- |
| [AI Runtime Security](examples/ai-runtime-security/README.md) | A confidential-information topic and an application security profile |
| [AI Red Teaming](examples/ai-red-teaming/README.md) | An authenticated application target and custom prompt-set container |
| [AI Gateway](examples/ai-gateway/README.md) | Owned model connections, four routing lessons, AIRS guardrails, application keys, request/token policies, and optional platform capabilities |
| [AI Supply Chain Security](examples/ai-supply-chain-security/README.md) | A Model Security group and security-rule discovery |

Each directory is an independent Terraform root with its own state. Start with one product; you do not need to apply all four. The examples pin provider **0.9.0**. Gateway requires Terraform **1.9 or later**; the other roots require **1.8 or later**. All require Terraform before 2.0.

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

Examples create their own named configuration and reference externally provisioned workspaces, application endpoints, and tenant integrations where documented. Gateway creates its upstream connections and bindings; its optional organization policy is organization-scoped and explicitly attached to the owned configurations. Read its [platform guide](examples/ai-gateway/platform.md) before enabling optional features. [Resource ownership](docs/adr/0001-example-resource-ownership.md) explains cleanup boundaries.

Terraform files use short `# Concept: purpose` comments at concept boundaries and multiline objects for nested configuration. Keep comments focused on dependencies and product behavior; variable descriptions explain individual inputs.

Run `python3 scripts/validate.py` to check formatting, Registry installation, provider schema validation, and request-helper tests without tenant credentials. An optional [GitHub Actions template](ci/README.md) runs those checks in CI. Recorded live results and their limits are in [validation documentation](docs/validation.md); short sanitized output excerpts appear in the guides.

Supply Chain Skill Scanning coverage will be added after the supporting provider release is published and validated. The current released example uses Model Security.

See the [glossary](GLOSSARY.md) for product terminology. This community repository uses the MIT license.
