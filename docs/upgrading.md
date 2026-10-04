# Upgrade to provider 0.10.0

All four roots install the signed Registry provider `cdot65/prisma-airs` **0.10.0** with committed lock files. Use Terraform **1.11+**, before 2.0. Existing v0.9.0 resource addresses remain intact; new lessons are optional.

Before changing an existing deployment, back up its state securely and keep the same tenant credentials, prefixes, workspace selection, and input values. Pull the examples updates, run `terraform init -upgrade`, then review `terraform plan`. Commit a regenerated lock only when deliberately changing the pin.

| Release | Example coverage |
| --- | --- |
| v0.7.0 | Native Red Team payloads and profile revision lifecycles; earlier JSON configurations require the provider migration guide |
| v0.8.0 | Product-prefixed Runtime and Supply Chain types and nested endpoint configuration |
| v0.9.0 | Gateway connections, four routing lessons, guards, credentials, limits, MCP, secrets, and deployment registration |
| v0.10.0 | Managed/external Gateway workspace scopes, safe workspace discovery, Skill Scanning onboarding, rule baselines, trust, scans/findings/statistics |

The release coverage table maps **every current resource and data source**, including import-only and prerequisite-heavy lessons. Examples target the latest release rather than maintaining separate state roots for each historical version. [Provider migration instructions](https://cdot65.github.io/terraform-provider-prisma-airs/guides/migration/) describe pre-v0.8 address changes; do not re-create production resources to upgrade their names.

Gateway continues using an existing workspace unless `create_workspace` is enabled. Switching that option for existing state moves all child references and can replace resources; it is a new workflow, not an automatic migration. Skill Scanning stays off until you supply its endpoints and entitlement. Rule/instance management requires a separate explicit opt-in. Import-only Runtime applications and Skill Scanning instances have deletion protection; see their guides before cleanup.

Historical v0.9.0 receipts and the comment-only readability comparison remain preserved. Their source hashes describe those revisions. The new v0.10.0 receipts describe the newly validated configuration and clearly distinguish exercised options from offline-only lessons.
