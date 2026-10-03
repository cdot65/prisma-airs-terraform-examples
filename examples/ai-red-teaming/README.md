# AI Red Teaming

Register an authenticated application target using native HCL request/response templates, and create a custom prompt-set container for its assessment workflow. The target application and its credentials exist outside this Terraform project.

| Managed object | Purpose |
| --- | --- |
| `prisma-airs_red_team_target.application` | Endpoint, payload templates and sensitive authentication headers |
| `prisma-airs_red_team_custom_prompt_set.assessment` | Named custom attack-prompt collection |

Provider 0.9.0 manages the prompt-set container. Populate its prompts through the AIRS console/CLI separately. Creating the target does not probe the endpoint or start an assessment.

## Inputs and authentication

Supply shared management credentials through the `PANW_MGMT_*` environment variables or the tenant helper. The service account needs Red Team management access.

| Input | Purpose |
| --- | --- |
| `name_prefix` | Unique prefix for the new target and prompt set |
| `target_endpoint` | Actual HTTPS endpoint you are authorized to assess |
| `request_body` | Native request object containing `{INPUT}` |
| `response_body` | Native response template containing `{RESPONSE}` |
| `response_key` | Field holding response text |
| `target_auth_headers` | Sensitive map loaded through `TF_VAR_target_auth_headers` |
| `description_suffix` | Editable annotation; defaults to `initial` |

Copy `terraform.tfvars.example` to `terraform.tfvars` and replace the endpoint and templates with your application's real contract. Its sample URL/payload are placeholders. Load authentication headers from your credential store as a JSON object in `TF_VAR_target_auth_headers`; they are retained in sensitive Terraform state and are never outputs.

The live vulture run reused a preexisting validated Runtime endpoint and its header authentication as inputs to a new disposable registration. The existing target was neither imported nor changed.

## Execute

From this directory, after supplying the endpoint, templates and authentication:

```bash
export TF_VAR_name_prefix="tf-redteam-$(date -u +%Y%m%d%H%M%S)"
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

Validated on **vulture** at **2026-10-03T12:23:25Z**, using Terraform **1.16.4** and the signed Registry provider **0.9.0**. This is a sanitized excerpt of the actual console output: resource progress, tenant/resource identifiers, endpoint details and credentials are omitted. Summary lines are preserved verbatim. Both unchanged-plan commands exited `0`.

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

Output values recorded after the update (identifiers replaced with placeholders):

```text
Outputs:

prompt_set_id = "<prompt-set-id>"
target_id = "<target-id>"
```

Both resource identities stayed stable through the description updates. Independent cleanup reads returned HTTP 404 for the disposable target and `active = false` for the prompt set. The archived prompt-set record remains in AIRS. The original target remained active.

No prompts were uploaded and no assessment or inference request was executed during validation. The recorded run proves the target/prompt-set configuration lifecycle.

[Provider workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/red-team-testing/) · [Repository validation](../../docs/validation.md)
