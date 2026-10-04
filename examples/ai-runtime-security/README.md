# Get started with AI Runtime Security

Create an application policy that blocks prompt injection and detects confidential business information. Terraform creates a custom topic and a security profile that references it.

## Before you start

Install Terraform 1.11 or later, before 2.0, and load the three [management environment variables](../../README.md#get-started). Your service account needs Runtime Security management access. This project uses provider 0.10.0 and needs no existing application endpoint.

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

A sanitized excerpt from the historical provider 0.9.0 live run (new release evidence is linked below):

```text
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Terraform outputs the topic ID, current profile revision ID, and revision number. The profile is named `<name_prefix>-application-policy`; a new profile starts at revision 1.

## Use the policy

Open the created profile in Prisma AIRS to inspect prompt-injection and topic protection. When integrating the Runtime Security Scan API with your application, select this profile by name. Application scan requests need a separate Runtime Security API key; the management OAuth variables used by Terraform do not authenticate those requests.

Applying this project configures the policy. It does not send content for inspection. Follow the [security-profile workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/managing-security-profiles/) to connect the profile to your application.

## Add scanning access or adopt an application

The default lesson creates only the topic and policy. Optional controls cover the remaining Runtime resources and discovery:

| Input | Lesson |
| --- | --- |
| `enable_runtime_discovery = true` | Read DLP and deployment profiles; profiles and auth codes remain in sensitive state |
| `create_scanning_key = true` | Issue a key for this example's disposable scanner application |
| `scanning_environment`, `scanning_cloud_provider` | Customer-app labels (default `dev`/`aws`); this creates no cloud infrastructure |
| `deployment_profile_name` | Exact name in the first 100 deployment profiles; the plan rejects missing or ambiguous matches |
| `existing_customer_app_name` | Adopt an existing app by import; it cannot be created by this resource |

Keep `name_prefix` at most 27 characters when issuing a key. Find the authorized deployment profile name in your tenant before enabling key creation. Retrieve the one-time `scanning_api_key` through your secure output workflow. A refresh retains a creation-time key; import cannot retrieve the original secret. Key inputs, including rotation settings, require replacement. Deleting a key also deletes its associated app, so this example always uses its own scanner app and rejects importing that app separately.

For an **unrelated existing app**, set `existing_customer_app_name`, then import before apply:

```bash
terraform import 'prisma-airs_runtime_customer_app.existing[0]' 'YOUR_EXISTING_APP_NAME'
terraform plan
```

Its `prevent_destroy` guard intentionally blocks general cleanup while adopted. To leave it with its external owner, back up state securely, set the input back to null, and remove only the binding before planning cleanup:

```bash
umask 077
terraform state pull > app-adoption-backup.tfstate
terraform state rm 'prisma-airs_runtime_customer_app.existing[0]'
terraform plan -destroy -out=destroy.tfplan
```

State removal does not delete the app. Keep the backup private; never remove that lifecycle guard merely to finish the example. See the [application lifecycle guide](https://cdot65.github.io/terraform-provider-prisma-airs/resources/customer-app/) for update prerequisites and unsupported renames.

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

[Provider 0.10.0 live evidence](../../docs/live-runs/provider-0.10.0.md) · [Complete release coverage](../../docs/resource-coverage.md)
