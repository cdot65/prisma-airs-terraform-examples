# Independent feature review

Use a fresh Codex session with the examples repository checked out to `feat/gateway-platform-reference`. Resolve the branch HEAD once and keep that commit fixed throughout the review.

```text
Use $code-review to independently review the feature branch against base commit
da7af613d2f03b7bb518f7db066c288197b8b8ac.

Read the repository instructions, GLOSSARY.md, the ownership ADR, and
docs/plans/ai-gateway-example-scope.md to establish standards and requirements.
Review the complete diff through the fixed HEAD, including Terraform, Python
request helpers, all getting-started guides, and recorded evidence.

Run python3 scripts/validate.py with Terraform on PATH. Examine whether the
configuration and instructions support a newcomer following the documented
journey, whether optional capabilities meet their stated contracts, and whether
runtime and cleanup claims are supported by the recorded evidence. Consult
primary provider/API documentation when needed.

Report actionable bugs, regressions, and specification mismatches with severity,
file and line, evidence, and practical impact. Separate verified findings from
questions or untested assumptions. Report validation results and remaining gaps.
Do not assume the implementation author's conclusions are correct.

Do not edit files, access tenant credentials, or perform live API writes.
```
