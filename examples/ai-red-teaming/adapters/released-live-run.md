# Recorded Registry-provider run

Real Vulture output on 2026-10-04 using Terraform **1.16.4** and signed Registry provider **0.12.0**. The public HCL and Python were copied unchanged into a private directory; management credentials were loaded as environment variables. Resource and signing-key identifiers are replaced with labeled placeholders. These excerpts are captured output, not fabricated data.

## Registry installation

```text
- Installed cdot65/prisma-airs v0.12.0 (self-signed, key ID <provider-signing-key-id>)
```

## Draft apply

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
adapter_id = "<adapter-uuid>"
adapter_status = "DRAFT"
discovered_adapter_status = "DRAFT"
```

## Activation apply

```text
Apply complete! Resources: 1 added, 1 changed, 0 destroyed.
adapter_id = "<adapter-uuid>"
adapter_status = "ACTIVE"
discovered_adapter_status = "ACTIVE"
target_id = "<target-uuid>"
```

## No op plan

```text
No changes. Your infrastructure matches the configuration.
```

The ordinary plan exited **0**.

## Cleanup apply

```text
Apply complete! Resources: 0 added, 0 changed, 2 destroyed.
```

## Independent cleanup

```text
prisma-airs_red_team_adapter: HTTP404 confirmed
prisma-airs_red_team_target: HTTP404 confirmed
Remaining original adapters: 3
```

Separate API GETs confirmed both owned resources absent after Terraform cleanup. Draft creation did not execute the script; activation ran its bounded deterministic text reply and registered the target. This demonstrates connectivity, not a model-security assessment. Existing adapters and the Network Broker channel remain in place.

## Source hashes

SHA-256 of the unchanged public source used for this released run:

```text
4da58b09693e1c6376a3b483dc673d425cbe388d79b6a20ccf1aee647a07033e  main.tf
18b54e210e7d6647a18ec5299f1f4c8d047a50bae565f642a8564edbdaa4d9ec  variables.tf
ce3b43a7984c110cf88e8d5255e6447ccfaafd51fbf8c24d64fb77b894ddf741  outputs.tf
6c19abcc8080c35f37418060cd20fc277bf6d24032ed914b2d50e5d5371b5e16  adapter.py
```

The earlier [development run](live-run.md) and its receipt remain separate historical evidence.
