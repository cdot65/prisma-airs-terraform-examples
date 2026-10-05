# Recorded tenant cutover

These results come from the real Vulture adoption and Forgejo workflow, not mock
responses. Tenant/resource identifiers, state lineage, and private credentials are
omitted or replaced with labeled placeholders. The public folder is the CI/CD
harness; the executed private root owns the imported configuration.

| Product | Imported managed resources |
| --- | ---: |
| AI Runtime Security | 179 |
| AI Red Teaming | 13 |
| AI Gateway | 152 |
| AI Supply Chain Security | 13 |
| Total | 357 |

Conjur's workload JWT authenticated and retrieved an allowed variable (HTTP 200).
An unrelated existing variable's permission check was denied (HTTP 404, hiding
existence), and a wrong-audience JWT was rejected (HTTP 401). No unrelated secret
value was retrieved. All 26 scoped variables passed protected round-trip checks.

The dedicated MinIO bucket has versioning. A duplicate conditional write was
rejected (HTTP 412); scoped access to an unrelated bucket was rejected (HTTP 403).
Two local-only Terraform probe projects contended for one S3 lock: the second
plan failed with `Error acquiring the state lock`; cleanup removed the disposable
resource and released the lock. These probes made no tenant writes.

Migration retained all 357 address/identity pairs. Terraform initially reset
lineage/serial during the local-to-S3 copy; an operator restored the verified
original state after confirming identical identities and no concurrent writer.
The original lineage was preserved, with serial advancing 392 → 393.

The first live plan after splitting secrets exposed 189 sensitivity-marker-only
updates. No values differed, and no apply was attempted. Removing those new
inventory annotations restored a clean plan; review text instead redacts current
and observed old credentials without changing resource sensitivity metadata.

The real migrated-root plan then reported:

```text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

Initial Forgejo main plans (runs 1 and 2) and a trusted branch PR plan (run 4)
succeeded with 357 no-op actions. First manual apply (run 3) was refused because
its drift guard compared against older persisted attributes: three Gateway
`last_updated_at` changes were already in the reviewed snapshot. The corrected
guard compares fresh observations with the reviewed plan's refreshed `prior_state`
and retains rejection of new drift. Regression tests cover both cases.

The next manual apply (run 8) was also refused before writes: the guard read
`planned_values` from refresh-only JSON, which contains no managed resources in
Terraform 1.16.4. The refreshed observations actually reside in
`prior_state.values`. All 357 observations matched review. Tests now model that
real response shape, and Codex independently replayed the captured pair and
verified that changing or removing an object still causes rejection.

At private source commit `e381d9b0f6a84778f4156f605e8df97a9378a1eb`, main plan
**run 9** succeeded with **357 no-op actions**. The operator reviewed its text and
verified the binary SHA256 before manually dispatching **run 10**, which
successfully applied that exact saved plan with `noop_only=true`.

This is the real `apply-result.json`, with only the state lineage sanitized:

```json
{
  "plan_id": "4448-1",
  "commit": "e381d9b0f6a84778f4156f605e8df97a9378a1eb",
  "applied": true,
  "noop": true,
  "state": {
    "lineage": "<private-state-lineage>",
    "serial": 394,
    "managed_resources": 357
  }
}
```

An independent post-apply comparison confirmed **all 357 original identities**
and the original lineage. Serial advanced 392 → 393 during migration and
393 → 394 during the no-op apply. Bucket versioning remained enabled. The scoped
job credential cannot inspect bucket-versioning administration; operator
metadata verification used a separate administrative identity.

| Forgejo run | Result |
| --- | --- |
| 4 — trusted private branch PR | Success, 357 no-op actions |
| 9 — final main plan | Success, 357 no-op actions |
| 10 — manual exact saved-plan apply | Success, no-op, 357 identities preserved |
| 11 — post-apply main plan | Success, exit 0, 357 no-op actions |

The [machine-readable receipt](live-receipt.json) records the executed private
commit, public helper hashes, and sanitized outcomes. The generic public runner
image/names/endpoints are templates; the live deployment used the private
repository's existing job image and its dedicated repository runner.

Six prior API/access cases remain outside the safely owned inventory: four
Gateway workspace IAM-scope reads and one listed provider read return 404, and
one Skill Scanning instance read returns 403. This CI/CD cutover does not repair
those external blockers or invent unavailable credentials.

Independent Codex review of the final implementation rated Standards **9.2/10**
and Spec **9.3/10**, with no remaining actionable findings. This proves the
no-op adoption/cutover workflow; configuration-changing applies remain deliberate
future changes, subject to the same reviewed-plan controls.
