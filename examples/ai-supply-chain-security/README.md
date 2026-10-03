# AI Supply Chain Security

Create a Model Security group for Hugging Face models and discover the Model Security rule catalog. Model Security is the model-focused capability within AI Supply Chain Security.

| Object | Purpose |
| --- | --- |
| `prisma-airs_supply_chain_security_group.models` | Named model security group with an editable description |
| `data.prisma-airs_supply_chain_security_rules.catalog` | Available rule names and count |

## Inputs and authentication

Supply shared `PANW_MGMT_*` environment credentials or use the tenant helper. The tenant must have Model Security entitlement and the service account must have its management roles; Runtime/Gateway access alone does not establish that access.

| Input | Required | Default |
| --- | --- | --- |
| `name_prefix` | Yes; unique, previously unused | — |
| `description_suffix` | No | `initial` |

The group uses `HUGGING_FACE`. Changing its source type requires replacement. This example creates an empty group and reads rules; it does not upload models or initiate model scans.

## Execute

Run from this directory:

```bash
export TF_VAR_name_prefix="tf-supply-chain-$(date -u +%Y%m%d%H%M%S)"
terraform init
terraform validate
python3 ../../scripts/with-tenant.py vulture terraform plan -out=create.tfplan
python3 ../../scripts/with-tenant.py vulture terraform apply create.tfplan
python3 ../../scripts/with-tenant.py vulture terraform plan -detailed-exitcode

export TF_VAR_description_suffix=updated
python3 ../../scripts/with-tenant.py vulture terraform plan -out=update.tfplan
python3 ../../scripts/with-tenant.py vulture terraform apply update.tfplan
python3 ../../scripts/with-tenant.py vulture terraform apply -refresh-only
python3 ../../scripts/with-tenant.py vulture terraform plan -detailed-exitcode

python3 ../../scripts/with-tenant.py vulture terraform destroy
python3 ../../scripts/with-tenant.py vulture terraform state list
```

An unchanged plan exits `0`; `2` means proposed changes; `1` means an error. With credentials already exported, omit the Python helper.

## Recorded live run

Validated on **vulture** at **2026-10-03T12:22:44Z**, using Terraform **1.16.4** and the signed Registry provider **0.9.0**. This is a sanitized excerpt of the actual console output: resource progress, tenant/resource identifiers, endpoint details and credentials are omitted. Summary lines are preserved verbatim. Both unchanged-plan commands exited `0`.

```text
$ terraform plan -out=create.tfplan
Plan: 1 to add, 0 to change, 0 to destroy.

$ terraform apply create.tfplan
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

$ terraform plan -detailed-exitcode
No changes. Your infrastructure matches the configuration.

$ terraform plan -out=update.tfplan
Plan: 0 to add, 1 to change, 0 to destroy.

$ terraform apply update.tfplan
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

$ terraform apply -refresh-only -auto-approve
No changes. Your infrastructure still matches the configuration.
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

$ terraform plan -detailed-exitcode
No changes. Your infrastructure matches the configuration.

$ terraform destroy -auto-approve
Plan: 0 to add, 0 to change, 1 to destroy.
Destroy complete! Resources: 1 destroyed.
```

Output values recorded after the update (identifiers replaced with placeholders):

```text
Outputs:

group_id = "<group-id>"
rule_count = 12
```

The live catalog contained **12 rules**. The group kept its identity through the description update. After destroy, its API record had `is_tombstone = true`. The API can still report `state = ACTIVE` on a tombstoned record, so the tombstone flag is the deletion evidence. Terraform removed it from state. The rule catalog was read without changing tenant policy.

## Upcoming Skill Scanning coverage

The provider's ongoing Skill Scanning additions will extend this project with catalog/effective-policy discovery and a disposable trust override. The local candidate passed create, replacement, refresh/empty-plan and destroy checks on vulture. It is not yet a published provider release, so that configuration is held for release verification before inclusion here.

The planned override uses a synthetic SHA-256 fingerprint for lifecycle validation, not the fingerprint of a deployed skill. Tenant-wide instance management and existing shared rule-policy changes are outside this example's fixture scope. Scans, uploads and assessment execution remain separate operations.

[Provider workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/model-security-workflow/) · [Repository validation](../../docs/validation.md)
