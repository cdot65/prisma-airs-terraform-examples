# ai-supply-chain-security — recorded lifecycle


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
