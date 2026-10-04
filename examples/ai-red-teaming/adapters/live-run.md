# Recorded adapter run

Real Vulture output on 2026-10-04 using Terraform 1.16.4 and the development provider based on v0.11.0. The upcoming provider release is not published yet. Tenant/resource identifiers are replaced with labeled placeholders; commands and results are recorded, not fabricated.

The public HCL and Python files were copied unchanged into a private directory. Only private tfvars supplied an unused name and the existing broker channel. A temporary provider development override selected the candidate binary; production getting-started commands will use the released Registry provider.

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

## Destroy

```text
Destroy complete! Resources: 2 destroyed.
```

Draft writes explicitly disabled execution. Activation executed the deterministic text-only script and succeeded, then registered a target with a null response mode. An ordinary post-apply plan exited 0. Cleanup deleted both owned resources.

A separate disposable fixture also confirmed null-preserving adapter secret updates: its script asserted the original SECRET value after a VAR edit. Import and refresh executed no scripts; matching the documented transient prompt default yielded an empty import plan. Separate SDK reads confirmed HTTP404 for those fixtures.

## Source hashes

SHA-256 of the actual public files used for this run:

```text
4da58b09693e1c6376a3b483dc673d425cbe388d79b6a20ccf1aee647a07033e  main.tf
18b54e210e7d6647a18ec5299f1f4c8d047a50bae565f642a8564edbdaa4d9ec  variables.tf
ce3b43a7984c110cf88e8d5255e6447ccfaafd51fbf8c24d64fb77b894ddf741  outputs.tf
6c19abcc8080c35f37418060cd20fc277bf6d24032ed914b2d50e5d5371b5e16  adapter.py
```
