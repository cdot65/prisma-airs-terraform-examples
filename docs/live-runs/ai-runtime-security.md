# ai-runtime-security — recorded lifecycle


Validated on **vulture** at **2026-10-03T12:23:04Z**, using Terraform **1.16.4** and the signed Registry provider **0.9.0**. This is a sanitized excerpt of the actual console output: resource progress, tenant/resource identifiers, endpoint details and credentials are omitted. Summary lines are preserved verbatim. Both unchanged-plan commands exited `0`.

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

Output values recorded after the update (identifiers replaced with placeholders):

```text
Outputs:

profile_id = "<profile-revision-id>"
profile_revision = 2
topic_id = "<topic-id>"
```

The live update advanced the profile from revision 1 to revision 2 at the same Terraform address. The profile revision UUID changed as expected; the topic retained its identity. No scan request was executed. This proves configuration management, rather than the effectiveness of the policy against a particular prompt.

Destroy deletes every revision under the managed profile name. Complete post-destroy profile and topic inventories confirmed that both owned names were absent. Use a fresh prefix and do not import an existing production profile into this disposable example.

[Provider workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/managing-security-profiles/) · [Repository validation](../validation.md)
