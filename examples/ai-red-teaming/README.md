# Get started with AI Red Teaming

Register an authenticated application as a Red Team target and create a custom prompt-set container. Terraform manages the endpoint contract, request/response templates, authentication headers, and collection metadata.

## Before you start

Install Terraform 1.8 or later, before 2.0, and load the three [management environment variables](../../README.md#get-started). Your service account needs Red Team management access. Provider 0.9.0 is pinned by this project.

You also need a reachable application endpoint, its real request/response format, and any authentication headers. The target application is provisioned separately.

## Configure and apply

```bash
cp terraform.tfvars.example terraform.tfvars
```

Replace the sample endpoint and payload templates with your application's contract. Choose an unused `name_prefix`, such as `tf-redteam-yourname`.

| Input | What to supply |
| --- | --- |
| `name_prefix` | Unique names for the target and prompt set |
| `target_endpoint` | Your application's HTTPS endpoint |
| `request_body` | Native object containing the `{INPUT}` placeholder |
| `response_body` | Native response template containing `{RESPONSE}` |
| `response_key` | Field containing response text |
| `target_auth_headers` | Sensitive header map from the environment |
| `description_suffix` | Optional editable annotation; default `initial` |

Load `TF_VAR_target_auth_headers` from your credential store as a JSON object, for example a map containing your application's `Authorization` header. Do not paste credentials into the input file or commit them. Sensitive headers are retained in Terraform state.

```bash
terraform init
terraform plan -out=create.tfplan
terraform apply create.tfplan
terraform output
```

A sanitized excerpt from the recorded live run:

```text
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
Outputs:

prompt_set_id = "<prompt-set-id>"
target_id = "<target-id>"
```

## Prepare an assessment

Find the new target using `target_id` in Prisma AIRS and validate its connectivity and response parsing. Add attack prompts to the named custom prompt set through the console or CLI, then select the target and prompts for your assessment.

Provider 0.9.0 manages the prompt-set container; it does not populate its prompts. Applying Terraform does not validate endpoint connectivity or launch an assessment. The [Red Team workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/red-team-testing/) explains these separate steps.

## Make a change

Edit `description_suffix` in your input file, then review and apply:

```bash
terraform plan -out=update.tfplan
terraform apply update.tfplan
```

Description changes update the existing target and prompt-set metadata. If the application contract changes, update its templates and validate connectivity again before an assessment.

## Clean up

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Terraform deletes the owned target and archives the prompt set. An archived prompt-set record can remain visible in AIRS; the external application remains available.

If target validation fails, check the endpoint, header JSON, placeholder placement, and response field. If management authentication fails, check the environment and Red Team roles.

[Detailed live output and cleanup evidence](../../docs/live-runs/ai-red-teaming.md) · [Validation boundaries](../../docs/validation.md)
