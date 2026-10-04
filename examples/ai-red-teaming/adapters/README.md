# Get started with Red Team adapters

Own a Python adapter and register an adapter-backed Red Team target. The starter script returns a deterministic text response through Network Broker; it teaches connectivity and Terraform dependencies without an upstream model key. Replace `call_target` with your application's call before preparing a real assessment.

This project targets the upcoming provider 0.12.0. It is not installable from the Registry until that release is published; current validation uses the development build. The released parent Red Team project remains available separately.

## Save a draft

Install Terraform 1.11 or later, before 2.0. Load `PANW_MGMT_CLIENT_ID`, `PANW_MGMT_CLIENT_SECRET`, and `PANW_MGMT_TSG_ID` from your secret store. Your account needs Red Team management access.

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out=draft.tfplan
terraform apply draft.tfplan
terraform output
```

Choose an unused `name_prefix`. Leave `activate = false` for the first apply: Terraform saves the script and variables as a draft without executing the script or creating the target. Scripts and variable values are sensitive and are still stored in state and saved plans.

## Activate and register a target

You need an existing online Network Broker channel with text adapter support. Channel registration alone does not install the broker or ensure a compatible client. Terraform does not create, repair, upgrade, or delete that prerequisite.

Inspect `adapter.py`, then set your `network_broker_channel_uuid` and `activate = true` in `terraform.tfvars`:

```bash
terraform plan -out=activate.tfplan
terraform apply activate.tfplan
terraform output
terraform plan -detailed-exitcode
```

Activation executes the script using a text-only validation prompt. After activation succeeds, Terraform registers the adapter-backed target without launching an assessment. Every later adapter update with `activate = true` executes the script again. Refresh, lookup, import, and no-op plans do not execute it.

Use `target_id` in Prisma AIRS when preparing an assessment of your actual application. This deterministic response is a connectivity fixture, not a model-security benchmark.

## Discover or adopt an existing adapter

The project demonstrates both discovery data sources. `red_team_adapters.ids_by_name` resolves exact names to UUIDs; `red_team_adapter` reads the selected configuration without execution or additional ownership. Duplicate names fail rather than choosing an arbitrary adapter. Use a resource reference for an adapter this project owns so Terraform orders target creation and destruction correctly.

To adopt an existing adapter, first edit this configuration to match its name, script, channel, and complete variable inventory, then import:

```bash
terraform import prisma-airs_red_team_adapter.example '<adapter-uuid>'
terraform plan
```

Match the imported `validate` setting: true for ACTIVE adapters, false for DRAFT. This project's `activate` also controls target creation, so match or import the target as well before expecting an empty plan. Import the target at `prisma-airs_red_team_target.example[0]` using `adapter/<target-uuid>` when activation is enabled. Protect any existing object you adopt with an appropriate `prevent_destroy` lifecycle before planning changes.

The API redacts SECRET values. Preserve every key and type; use `value = null` for an unchanged imported SECRET. A later update retains that stored value. An omitted key is deleted. New variables or type changes require real values; masks such as `********` are rejected. Load original values through `TF_VAR_adapter_variables` when writing new secrets.

Adapter target overrides have their own complete key map. Unlike adapter base variables, missing imported override secrets must be supplied before writing the target. Endpoint targets also allow no-op adoption without original credentials; complete inputs remain required before create/update.

## Clean up

```bash
terraform plan -destroy -out=cleanup.tfplan
terraform apply cleanup.tfplan
```

Terraform removes the dependent target first, then the adapter. It leaves the existing broker channel and other discovered adapters in place. Do not use cleanup on an adopted production configuration unless destruction is intended.

## Recorded run

See [live-run.md](live-run.md) for real sanitized development-build output, execution results, and the scope of validation.
