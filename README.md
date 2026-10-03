# Prisma AIRS Terraform Examples

Working Terraform projects for declaratively configuring Prisma AIRS with the [Prisma AIRS provider](https://registry.terraform.io/providers/cdot65/prisma-airs/latest). Each product has an independent Terraform root, its own state, execution instructions, and output recorded from a live validation run.

| Product | Project | Configuration |
| --- | --- | --- |
| AI Runtime Security | [ai-runtime-security](examples/ai-runtime-security/) | Confidential-information topic and application security profile |
| AI Red Teaming | [ai-red-teaming](examples/ai-red-teaming/) | Authenticated application target and custom prompt-set container |
| AI Gateway | [ai-gateway](examples/ai-gateway/) | Routing through an existing provider and an application-scoped rate policy |
| AI Supply Chain Security | [ai-supply-chain-security](examples/ai-supply-chain-security/) | Model Security group and security-rule discovery |

The four projects pin the signed, publicly installable provider **0.9.0** and were validated on **vulture** with Terraform **1.16.4**. Validation covers create, update, refresh, empty plans, and destroy. The READMEs contain sanitized excerpts from those actual runs. [Validation details](docs/validation.md) define the evidence and cleanup behavior.

Skill Scanning additions are being prepared against the upcoming provider release. They will be incorporated into the Supply Chain project after that provider is published and the example passes validation with its released binary. The existing project uses published Model Security functionality.

## Prerequisites

- Terraform 1.8 or later, before 2.0; the recorded runs used 1.16.4.
- A Prisma AIRS service account with roles and entitlement for the chosen product.
- The existing workspace/provider or target endpoint described in the product README.
- Python 3 and the AIRS CLI if using the optional tenant credential helper.

## Environment-based authentication

The provider reads these variables; credentials are never configured in HCL:

| Variable | Value |
| --- | --- |
| `PANW_MGMT_CLIENT_ID` | Service-account OAuth client ID |
| `PANW_MGMT_CLIENT_SECRET` | Service-account OAuth client secret |
| `PANW_MGMT_TSG_ID` | Tenant Service Group ID |

Load them into the current process from your credential store, then use Terraform normally. All projects contain an empty provider block and inherit the shared identity.

If the tenant is registered in the AIRS CLI, the optional helper reads its linked JSON and passes those three values only through the child process environment:

```bash
airs cli tenant list
python3 scripts/with-tenant.py vulture terraform -chdir=examples/ai-runtime-security init
```

The helper does not switch the selected CLI tenant, print credentials, or create a `.env` file. It disables provider debug logging for that child process. It reads `mgmtClientId`, `mgmtClientSecret`, and `mgmtTsgId` from the registered JSON.

## Run an example

From the repository root, choose a unique resource prefix and set the product-specific inputs from its README:

```bash
export TF_VAR_name_prefix="tf-demo-$(date -u +%Y%m%d%H%M%S)"
python3 scripts/with-tenant.py vulture terraform -chdir=examples/ai-runtime-security init
python3 scripts/with-tenant.py vulture terraform -chdir=examples/ai-runtime-security validate
python3 scripts/with-tenant.py vulture terraform -chdir=examples/ai-runtime-security plan -out=create.tfplan
python3 scripts/with-tenant.py vulture terraform -chdir=examples/ai-runtime-security apply create.tfplan
```

Review saved plans before applying. To clean up, run the corresponding `terraform destroy` with the same tenant, directory and inputs. Each product README gives a complete local workflow including updates and cleanup.

Each project includes `terraform.tfvars.example` for nonsecret inputs. Copy it to `terraform.tfvars` and replace its placeholders, or use the documented `TF_VAR_*` environment variables. Keep connection credentials in environment variables. State and saved plans can contain sensitive values even when console output hides them; both are excluded from Git.

## Checks and ownership

Run `python3 scripts/validate.py` to check formatting, provider installation from the Registry, and configuration validation without tenant credentials. Live validation is recorded separately. An [Actions workflow template](ci/validate.yml) runs the same checks in CI; [installation instructions](ci/README.md) explain how to enable it.

Examples own uniquely named disposable resources. Workspaces, upstream integrations, target applications and existing tenant policy remain external prerequisites. Destroy affects only objects created by the example, subject to the API's archival/tombstone behavior. [Ownership decision](docs/adr/0001-example-resource-ownership.md) explains this boundary.

See [GLOSSARY.md](GLOSSARY.md) for product terminology. This repository uses the MIT license and is a community example repository.
