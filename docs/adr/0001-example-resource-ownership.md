# Examples own application configuration and declare shared ownership explicitly

Each product root owns uniquely named application configuration. Gateway normally references an existing workspace, or opts in to owning a new workspace and dedicated IAM scope. External scope mode makes no IAM writes. Upstream integrations and their explicit bindings remain owned; infrastructure, membership, role grants, and tenant plugin administration remain external.

Shared Skill Scanning policy and onboarding require separate explicit opt-ins. Rules capture a baseline that destroy restores. Existing onboarding must be imported with its full desired registration payload; `prevent_destroy` blocks example cleanup. Import-only Runtime applications have the same deletion guard and remain unrelated to the example's disposable key/app association. Removing protected state bindings returns management to their external owner without deleting objects.

Optional organization guardrails remain organization-scoped and require deliberate enablement. Every guide explains prerequisite access, replacement or archive behavior, and cleanup boundaries. No example claims to execute scans merely by applying configuration.
