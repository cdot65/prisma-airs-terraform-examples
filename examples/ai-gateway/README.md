# AI Gateway

Create a versioned routing configuration that references an existing enabled Gateway provider, and a rate policy scoped to requests carrying the example's application metadata. Upstream credentials stay in the existing integration; the visible routing document contains only a provider reference.

| Object | Purpose |
| --- | --- |
| `prisma-airs_gateway_config.application` | Route to the selected provider/model with configurable retry attempts |
| `prisma-airs_gateway_rate_limit.application` | Requests-per-minute limit selected by application metadata |
| `data.prisma-airs_gateway_providers.workspace` | Read provider metadata from the workspace's first page |

## Inputs and authentication

Supply shared `PANW_MGMT_*` credentials or use the tenant helper. The service account needs Gateway management access to the selected workspace.

| Input | Required | Default |
| --- | --- | --- |
| `name_prefix` | Yes; also the request `metadata.application` value | — |
| `workspace_id` | Existing workspace UUID | — |
| `provider_slug` | Enabled provider slug in that workspace, without `@` | — |
| `model` | Model slug available through that provider | — |
| `retry_attempts` | No | `1` |
| `requests_per_minute` | No | `100` |

Fill these nonsecret values in `terraform.tfvars` from `terraform.tfvars.example`, or export their `TF_VAR_*` variables. Find the workspace and enabled provider/model in your Gateway environment. Workspace/IAM and provider/integration provisioning are prerequisites and are not managed by this example.

To select this rate policy during a later inference call, include `metadata.application` equal to `name_prefix` in the request. The example does not set a tenant default, issue a service key, deploy a Gateway, or generate inference traffic. The provider data source reads one page; `provider_count_on_first_page` is not the tenant's complete provider inventory.

## Execute

From this directory, after setting the existing workspace, provider and model:

```bash
export TF_VAR_name_prefix="tf-gateway-$(date -u +%Y%m%d%H%M%S)"
terraform init
terraform validate
python3 ../../scripts/with-tenant.py vulture terraform plan -out=create.tfplan
python3 ../../scripts/with-tenant.py vulture terraform apply create.tfplan
python3 ../../scripts/with-tenant.py vulture terraform plan -detailed-exitcode

export TF_VAR_retry_attempts=2
export TF_VAR_requests_per_minute=120
python3 ../../scripts/with-tenant.py vulture terraform plan -out=update.tfplan
python3 ../../scripts/with-tenant.py vulture terraform apply update.tfplan
python3 ../../scripts/with-tenant.py vulture terraform apply -refresh-only
python3 ../../scripts/with-tenant.py vulture terraform plan -detailed-exitcode

python3 ../../scripts/with-tenant.py vulture terraform destroy
python3 ../../scripts/with-tenant.py vulture terraform state list
```

An unchanged plan exits `0`; `2` means proposed changes; `1` means an error. With credentials already exported, omit the Python helper.

## Recorded live run

Validated on **vulture** at **2026-10-03T12:24:43Z**, using Terraform **1.16.4** and the signed Registry provider **0.9.0**. This is a sanitized excerpt of the actual console output: resource progress, tenant/resource identifiers, endpoint details and credentials are omitted. Summary lines are preserved verbatim. Both unchanged-plan commands exited `0`.

```text
$ terraform plan -out=create.tfplan
Plan: 2 to add, 0 to change, 0 to destroy.

$ terraform apply create.tfplan
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

$ terraform plan -detailed-exitcode
No changes. Your infrastructure matches the configuration.

$ terraform plan -out=update.tfplan
Plan: 0 to add, 2 to change, 0 to destroy.

$ terraform apply update.tfplan
Apply complete! Resources: 0 added, 2 changed, 0 destroyed.

$ terraform apply -refresh-only -auto-approve
No changes. Your infrastructure still matches the configuration.
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

$ terraform plan -detailed-exitcode
No changes. Your infrastructure matches the configuration.

$ terraform destroy -auto-approve
Plan: 0 to add, 0 to change, 2 to destroy.
Destroy complete! Resources: 2 destroyed.
```

The provider metadata source returned **2 providers on its first page**. The routing configuration retained its resource ID while receiving a new `version_id`. The rate policy retained its ID and changed from 100 to 120 requests per minute. Post-destroy GETs returned HTTP 404 for both owned objects; the existing provider remained active.

This verifies declarative configuration management. No upstream connectivity, actual rate enforcement or inference behavior was tested.

[Provider workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/gateway-workflow/) · [Repository validation](../../docs/validation.md)
