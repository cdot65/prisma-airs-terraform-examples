# Get started with AI Runtime Security

Create an application policy that blocks prompt injection and detects confidential business information. Terraform creates a custom topic and a security profile that references it.

## Before you start

Install Terraform 1.8 or later, before 2.0, and load the three [management environment variables](../../README.md#get-started). Your service account needs Runtime Security management access. This project uses provider 0.9.0 and needs no existing application endpoint.

## Configure and apply

From this directory:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit the file and choose a unique, unused `name_prefix`, such as `tf-runtime-yourname`. Leave `topic_action = "block"` for the initial policy. Credentials belong in the environment, not this file.

| Input | Purpose | Default |
| --- | --- | --- |
| `name_prefix` | Names your owned topic and profile | Required |
| `topic_action` | Action for confidential-information matches | `block` |
| `description_suffix` | Editable topic annotation | `initial` |

```bash
terraform init
terraform plan -out=create.tfplan
terraform apply create.tfplan
terraform output
```

A sanitized excerpt from the recorded live run:

```text
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Terraform outputs the topic ID, current profile revision ID, and revision number. The profile is named `<name_prefix>-application-policy`; a new profile starts at revision 1.

## Use the policy

Open the created profile in Prisma AIRS to inspect prompt-injection and topic protection. When integrating the Runtime Security Scan API with your application, select this profile by name. Application scan requests need a separate Runtime Security API key; the management OAuth variables used by Terraform do not authenticate those requests.

Applying this project configures the policy. It does not send content for inspection. Follow the [security-profile workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/managing-security-profiles/) to connect the profile to your application.

## Make a change

Edit `description_suffix` to annotate the topic, or change `topic_action` to explore an alternative policy action. Review and apply the resulting change:

```bash
terraform plan -out=update.tfplan
terraform apply update.tfplan
terraform output
```

A policy change can create a new profile revision. Keep `name_prefix` stable: renaming a profile creates another logical profile and preserves the old name outside this resource address.

## Clean up

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Destroy deletes the owned custom topic and every revision under the managed profile name. Use a fresh prefix for this example and keep its state until cleanup finishes.

If authentication fails, check the environment and service-account roles. If Terraform reports a name collision, choose an unused prefix before the first apply.

[Detailed live output and cleanup evidence](../../docs/live-runs/ai-runtime-security.md) · [Validation boundaries](../../docs/validation.md)
