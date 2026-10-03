# ai-gateway — recorded lifecycle


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

Output values recorded after the update (identifiers replaced with placeholders):

```text
Outputs:

config_id = "<config-id>"
config_version_id = "<config-version-id>"
provider_count_on_first_page = 2
rate_limit_id = "<rate-limit-id>"
```

The provider metadata source returned **2 providers on its first page**. The routing configuration retained its resource ID while receiving a new `version_id`. The rate policy retained its ID and changed from 100 to 120 requests per minute. Post-destroy GETs returned HTTP 404 for both owned objects; the existing provider remained active.

This verifies declarative configuration management. No upstream connectivity, actual rate enforcement or inference behavior was tested.

[Provider workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/gateway-workflow/) · [Repository validation](../validation.md)
