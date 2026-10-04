# Get started with AI Supply Chain Security

Create a Hugging Face Model Security group, then optionally explore Skill Scanning: discover policy, manage a synthetic trusted fingerprint, and read existing scan results. Provider **0.10.0** supplies both product areas.

## Before you start

Use Terraform 1.11 or later, before 2.0, and load the three [management environment variables](../../README.md#get-started). Model Security requires its entitlement and management roles. Skill Scanning requires its own entitlement, roles, and both endpoint bases; access to another AIRS product does not establish these permissions.

The default project creates an empty Model Security group and reads its rules. Uploading models or skills and starting scans remain separate CLI/SDK operations.

## Configure and apply

```bash
cp terraform.tfvars.example terraform.tfvars
# Choose an unused name_prefix; leave optional lessons disabled initially.
terraform init
terraform validate
terraform plan -out=create.tfplan
terraform apply create.tfplan
terraform output
```

`group_id` identifies the new group; `rule_count` and `rule_names` describe its Model Security catalog. Onboard your models separately through the [Model Security workflow](https://cdot65.github.io/terraform-provider-prisma-airs/guides/model-security-workflow/).

## Explore Skill Scanning

Configure the two bases for your entitled service region in the same shell. These documented service URLs are a starting point; credentials continue to come from your secret store:

```bash
export PANW_SKILL_SCANNING_DATA_ENDPOINT=https://api.apps.paloaltonetworks.com/aiag/data
export PANW_SKILL_SCANNING_MGMT_ENDPOINT=https://api.apps.paloaltonetworks.com/aiag/mgmt
```

Set `enable_skill_scanning = true`, review a plan, and apply. `skills.tf` reads the catalog and effective tenant policy, creates an override for a deterministic synthetic fingerprint, and looks up that exact override. It leaves shared rules and tenant onboarding unchanged. Use a unique prefix; do not reuse a real skill's fingerprint for this exercise.

`skill_rule_count` is the Skill Scanning catalog size. `trust_fingerprint` is the synthetic fingerprint whose trust will be removed on destroy. This demonstrates trust configuration, not successful skill analysis.

| Optional input | What it enables |
| --- | --- |
| `enable_skill_history = true` | One page of completed/failed scans and seven-day statistics |
| `skill_scan_uuid` | Detail, non-chain vulnerabilities, and attack-chain pages for an existing scan |
| `existing_skill_fingerprint` | Latest scan lookup for an already scanned fingerprint |
| `skill_tenant_id` | Read-only instance lookup; requires separate instance-read permission |
| `manage_skill_rule = true`, `skill_rule_uuid` | Adopt one shared rule by **catalog** UUID, with desired `skill_rule_state` |
| `manage_skill_instance = true`, `skill_instance` | Own complete tenant onboarding, with deletion protection |

History, findings, profiles, and registration details can contain secrets. Native `result` objects stay sensitive in state; page results are not complete inventories. `skill_statistics` is a sensitive output. Null statistics mean unavailable, not zero. Scan detail does not start or poll a job, and this provider cannot delete individual scans.

## Adopt a shared rule deliberately

Coordinate with the tenant owner before enabling rule management; the setting affects other skill users. Use a catalog UUID, not the effective rule-instance UUID, and manage that tenant/rule pair in only one state.

Set the desired state to `DISABLED`, `ALLOWING`, or `BLOCKING`. Creation captures the effective baseline, updates only that rule, and retains a stable Terraform identity. Destroy restores the captured baseline and confirms it. If no effective instance existed, restoration writes its catalog default as an explicit setting; it cannot restore an absent row. Import likewise captures the current state as its baseline.

The sensitive `adopted_rule_baseline` output records the state Terraform will restore. See the [rule lifecycle guide](https://cdot65.github.io/terraform-provider-prisma-airs/resources/skill-scanning-rule/).

## Adopt tenant onboarding carefully

Instance management is off by default and has `prevent_destroy = true`. Supply the entire authorized `skill_instance` object through your secure variable source, including identity/support-account fields and **complete** native `registration_details`. Do not reconstruct that payload from a partial GET response: PUT can deactivate profiles omitted from it.

Existing instances must be imported before any apply:

```bash
terraform import 'prisma-airs_supply_chain_skill_scanning_instance.tenant[0]' 'YOUR_SKILL_TENANT_ID'
terraform plan
```

The first apply after import sends the full registration payload. Use the [instance guide](https://cdot65.github.io/terraform-provider-prisma-airs/resources/skill-scanning-instance/) for its exact object contract and provisioning semantics. Load `TF_VAR_skill_auth_code` from your secret store and set the nonsecret `skill_auth_code_version` when changing the code. The input variable is ephemeral and the provider attribute is write-only, so that dedicated code is not stored in plan or state. Other sensitive registration metadata **is stored**. Increment the version with an omitted code only when deliberately clearing it.

To return onboarding to its external owner, back up state securely, set `manage_skill_instance = false`, remove only its state binding, and then plan cleanup:

```bash
umask 077
terraform state pull > onboarding-backup.tfstate
terraform state rm 'prisma-airs_supply_chain_skill_scanning_instance.tenant[0]'
terraform plan -destroy -out=destroy.tfplan
```

State removal does not delete the instance. Keep the backup private and retain the destruction guard. Instance mutations require authorized onboarding access; the live validation records any unavailable permissions rather than claiming a successful registration test.

## Make a change and clean up

Change `description_suffix`, review a saved plan, and apply. The group description updates in place; a changed trust reason replaces its immutable override. Changing the group source type also requires replacement.

```bash
terraform plan -out=update.tfplan
terraform apply update.tfplan
terraform plan -detailed-exitcode
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Release any protected imported instance binding first, as described above. Cleanup tombstones the Model Security group, removes owned trust, and restores any deliberately adopted rule baseline. Historical records can remain visible. A group reporting `state = ACTIVE` alone does not establish that it is not tombstoned.

[Provider 0.10.0 live evidence](../../docs/live-runs/provider-0.10.0.md) · [Complete resource coverage](../../docs/resource-coverage.md) · [Validation boundaries](../../docs/validation.md)
