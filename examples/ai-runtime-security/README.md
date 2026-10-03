# AI Runtime Security

Configure an application policy that blocks prompt injection and detects a custom topic for confidential business information. Terraform creates the topic first and passes its name into the profile; the provider resolves the topic reference.

| Managed object | Purpose |
| --- | --- |
| `prisma-airs_runtime_custom_topic.confidential` | Examples and description for confidential-information detection |
| `prisma-airs_runtime_security_profile.application` | Prompt-injection protection and a configurable topic action |

## Inputs and authentication

Use the shared `PANW_MGMT_CLIENT_ID`, `PANW_MGMT_CLIENT_SECRET`, and `PANW_MGMT_TSG_ID` environment variables, or the tenant helper below. The service account needs Runtime Security management access.

| Input | Required | Default |
| --- | --- | --- |
| `name_prefix` | Yes; unique, previously unused | — |
| `description_suffix` | No | `initial` |
| `topic_action` | No | `block`; also accepts `allow` |

`terraform.tfvars.example` contains only nonsecret inputs. Keep the prefix unchanged during the update: renaming a profile creates a new logical profile and preserves the previous name outside the current resource address.

## Execute

Run from this directory:

```bash
export TF_VAR_name_prefix="tf-runtime-$(date -u +%Y%m%d%H%M%S)"
terraform init
terraform validate
python3 ../../scripts/with-tenant.py vulture terraform plan -out=create.tfplan
python3 ../../scripts/with-tenant.py vulture terraform apply create.tfplan
python3 ../../scripts/with-tenant.py vulture terraform plan -detailed-exitcode

# Change a topic annotation and its action in the profile.
export TF_VAR_description_suffix=updated
export TF_VAR_topic_action=allow
python3 ../../scripts/with-tenant.py vulture terraform plan -out=update.tfplan
python3 ../../scripts/with-tenant.py vulture terraform apply update.tfplan
python3 ../../scripts/with-tenant.py vulture terraform apply -refresh-only
python3 ../../scripts/with-tenant.py vulture terraform plan -detailed-exitcode

python3 ../../scripts/with-tenant.py vulture terraform destroy
python3 ../../scripts/with-tenant.py vulture terraform state list
```

An unchanged plan exits `0`; `2` means Terraform proposes changes; `1` means an error. If credentials are already loaded into your environment, use the same commands without the Python helper.

## Recorded live run

Validated on **vulture** at **2026-10-03T12:23:04Z**, using Terraform **1.16.4** and the signed Registry provider **0.9.0**. This is a sanitized excerpt of the actual console output: resource progress, tenant/resource identifiers, endpoint details and credentials are omitted. Summary lines are preserved verbatim. Both unchanged-plan commands exited `0`.

```

Output values recorded after the update (identifiers replaced with placeholders):

```text
Outputs:

profile_id = "<profile-revision-id>"
profile_revision = 2
topic_id = "<topic-id>"
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
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

$ terraform plan -detailed-exitcode
No changes. Your infrastructure matches the configuration.

$ terraform destroy -auto-approve
Plan: 0 to add, 0 to change, 2 to destroy.
Destroy complete! Resources: 2 destroyed.
```

The live update advanced the profile from revision 1 to revision 2 at the same Terraform address. The profile revision UUID changed as expected; the topic retained its identity. No scan request was executed. This proves configuration management, rather than the effectiveness of the policy against a particular prompt.

Destroy deletes every revision under the managed profile name. Complete post-destroy profile and topic inventories confirmed that both owned names were absent. Use a fresh prefix and do not import an existing production profile into this disposable example.

[Provider workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/managing-security-profiles/) · [Repository validation](../../docs/validation.md)
