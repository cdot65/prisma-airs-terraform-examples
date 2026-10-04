#!/usr/bin/env python3
"""Check example coverage against the exact installed provider schema."""
import argparse
from pathlib import Path
import re
import subprocess
import json

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/resource-coverage.md"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Refresh the coverage table after validating all roots.")
    args = parser.parse_args()
    result = subprocess.run(["terraform", "providers", "schema", "-json"], cwd=ROOT / "examples/ai-supply-chain-security", text=True, capture_output=True, check=True)
    schema = json.loads(result.stdout)["provider_schemas"]["registry.terraform.io/cdot65/prisma-airs"]
    version_report = subprocess.run(["terraform", "version", "-json"], cwd=ROOT / "examples/ai-supply-chain-security", text=True, capture_output=True, check=True)
    version = json.loads(version_report.stdout)["provider_selections"]["registry.terraform.io/cdot65/prisma-airs"]
    locations = {}
    for path in sorted((ROOT / "examples").glob("*/*.tf")):
        for kind, name in re.findall(r'^\s*(resource|data)\s+"([^"]+)"\s+"[^"]+"\s*\{', path.read_text(), re.MULTILINE):
            locations.setdefault((kind, name), []).append(path.relative_to(ROOT).as_posix())
    expected = {(kind, name) for kind, group in [("resource", "resource_schemas"), ("data", "data_source_schemas")] for name in schema[group]}
    missing, extra = expected - locations.keys(), locations.keys() - expected
    if missing or extra:
        raise SystemExit(f"Coverage mismatch: missing={sorted(missing)}, unknown={sorted(extra)}")
    lines = ["# Released resource coverage", "", f"Provider **{version}**: **{len(schema['resource_schemas'])} resources** and **{len(schema['data_source_schemas'])} data sources**. This table is checked against the installed Registry provider, not an unreleased checkout. Entries include optional and import-only lessons; see each product README for prerequisites and validation limits.", "", "Run `python3 scripts/coverage.py` after installation to check freshness, or add `--write` to regenerate after adding a Terraform example.", "", "| Kind | Terraform type | Example configuration |", "| --- | --- | --- |"]
    for kind, name in sorted(expected):
        refs = ", ".join(f"[{p.removeprefix('examples/')}]({('../' + p)})" for p in dict.fromkeys(locations[(kind, name)]))
        lines.append(f"| {kind} | `{name}` | {refs} |")
    text = "\n".join(lines) + "\n"
    if args.write:
        DOC.write_text(text)
    elif not DOC.is_file() or DOC.read_text() != text:
        raise SystemExit("Coverage table is stale. Run python3 scripts/coverage.py --write.")
    print(f"Covered {len(schema['resource_schemas'])} resources and {len(schema['data_source_schemas'])} data sources from the installed provider.")


if __name__ == "__main__":
    main()
