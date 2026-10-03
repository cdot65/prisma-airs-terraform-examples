# Get started with AI Supply Chain Security

Create a Model Security group for Hugging Face models and discover the available Model Security rules. Model Security is the model-focused part of AI Supply Chain Security.

## Before you start

Install Terraform 1.8 or later, before 2.0, and load the three [management environment variables](../../README.md#get-started). The tenant needs Model Security entitlement and your service account needs its management roles. Access to another AIRS product does not establish Model Security access.

This project pins provider 0.9.0. It creates an empty group and reads the rule catalog; model uploads and scans are separate operations.

## Configure and apply

```bash
cp terraform.tfvars.example terraform.tfvars
```

Choose an unused `name_prefix`, such as `tf-models-yourname`.

| Input | Purpose | Default |
| --- | --- | --- |
| `name_prefix` | Names the owned model group | Required |
| `description_suffix` | Editable group annotation | `initial` |

```bash
terraform init
terraform plan -out=create.tfplan
terraform apply create.tfplan
terraform output
```

A sanitized excerpt from the recorded live run:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
Outputs:

group_id = "<group-id>"
rule_count = 12
```

The catalog size depends on your tenant and can change. `group_id` identifies the new group; `rule_count` reports the catalog read during apply.

## Use the group

Locate the group in Model Security and use its ID when onboarding your Hugging Face model workflow. Review the discovered security rules before choosing how to assess a model. This Terraform root does not upload a model, start a scan, or change the shared rule policy.

Follow the [Model Security workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/model-security-workflow/) for the next operations.

## Make a change

Edit `description_suffix`, then review and apply the metadata update:

```bash
terraform plan -out=update.tfplan
terraform apply update.tfplan
```

The group uses source type `HUGGING_FACE`; changing the source type requires replacement.

## Clean up

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

The API retains a tombstoned group record. It can still report `state = ACTIVE`, so that field alone does not establish active status. Terraform removes the owned group from state after deletion.

A permission error usually calls for checking Model Security entitlement and roles as well as the shared OAuth variables.

## Skill Scanning

Skill Scanning examples are prepared separately and will join this root after their supporting provider release is published and verified. The current installable example uses released Model Security capabilities.

[Detailed live output and cleanup evidence](../../docs/live-runs/ai-supply-chain-security.md) · [Validation boundaries](../../docs/validation.md)
