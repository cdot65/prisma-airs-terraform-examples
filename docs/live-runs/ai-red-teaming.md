# ai-red-teaming — recorded lifecycle


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

[Provider workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/red-team-testing/) · [Repository validation](../validation.md)
