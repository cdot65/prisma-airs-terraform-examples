# Enable GitHub Actions validation

The [workflow template](validate.yml) checks formatting, installs the pinned public provider, and validates all four projects and their mock feature plans. Coverage and Python helper tests run through `scripts/validate.py`; the matrix template runs the per-project Terraform checks. It uses no tenant credentials and never applies configuration.

To enable it:

```bash
mkdir -p .github/workflows
cp ci/validate.yml .github/workflows/validate.yml
```

Commit and publish that file with a GitHub credential permitted to write Actions workflows. Until enabled, run the same checks locally with `python3 scripts/validate.py`.
