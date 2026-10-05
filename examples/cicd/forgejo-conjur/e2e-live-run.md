# A real configuration change through Forgejo

The Vulture test continued beyond its no-op cutover using a disposable Runtime
custom topic. It was never attached to an application policy. All management and
backend credentials came from Conjur, and every apply used the exact reviewed
main-branch binary plan against the canonical MinIO state.

The name/UUID and state lineage are omitted from this public record. Workflow IDs,
Terraform action summaries, and verification counts below come from actual runs.

## Create and update

Create PR 2 passed trusted plan **4451**, then main plan **4452** reported:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

Apply **4453** intentionally kept `noop_only=true`. It was rejected with:

```text
First cutover apply must be a no-op
```

State stayed at **357 resources, serial 394**. Manual apply **4454** then used the
same reviewed main artifact `4452-1` with `noop_only=false`. It created only the
fixture: **358 resources, serial 395**. Independent paginated API reads matched
its UUID, name, description, and all three configured examples.

Update PR 3 passed trusted plan **4455**, then main plan **4456** reported:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

Manual apply **4457** applied exactly `4456-1`, changing only the fixture description.
Independent API verification confirmed the new description and unchanged examples
and identity: **358 resources, serial 396**. Every original resource remained
no-op in both plans, and all **357 original identities and lineage** were preserved.

## Refuse unsafe review inputs

Apply **4458** supplied a wrong checksum and failed before writes:

```text
Reviewed plan checksum does not match the stored artifact
```

Apply **4459** supplied the correct checksum for an older main plan and failed:

```text
Plan commit is stale; create and review a new main plan
```

State remained at **358 resources, serial 396** after both refusals. These were
expected negative tests, not unexplained pipeline failures.

## Cleanup and restore protections

Cleanup PR 4 passed plan **4460**, then main plan **4461** reported:

```text
Plan: 0 to add, 0 to change, 1 to destroy.
```

The private project temporarily approved a **pure delete only for the fixture's
exact Terraform address and observed UUID**. Every imported `prevent_destroy`
declaration stayed intact; other addresses, other UUIDs, and replacements remained
blocked. Both Codex review axes approved this narrow exception, and all **22**
control tests passed. It was never added to the reusable public harness.

Manual apply **4462** used exactly `4461-1` and deleted only the fixture. State
returned to **357 resources, serial 397**. Independent API inventory confirmed
zero fixture matches, and all original identities and lineage matched the baseline.

Restoration PR 5 passed a **357-resource no-op** plan (**4463**) and was merged.
The entire tracked project tree again matches pre-test commit `e381d9b`: the
fixture declaration, temporary exception, and four fixture-specific tests are gone.
The original **18** control tests pass. Restored main plan **4464** succeeded with
**357 no-op actions**; manual exact-plan apply **4465** succeeded with `noop=true`,
357 managed resources, and serial 397. Final reconciliation again matched every
original identity and the original lineage.

The [machine-readable receipt](e2e-receipt.json) binds the actual workflow results,
independent API checks, unchanged CI helpers, and restored control helpers to this
record. Temporary private cleanup controls differ deliberately from the public
unconditional gate and were removed after their single approved use.

This proves a bounded Runtime resource lifecycle through the CI/CD system while
refreshing all four products. It does not claim that resources in every product
were mutated or that the six previously documented API/access exclusions were
resolved.
