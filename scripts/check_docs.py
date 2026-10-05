#!/usr/bin/env python3
"""Check local Markdown links, evidence source hashes, and recorded test counts."""

from pathlib import Path
import hashlib
import json
import re
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]


def heading_slugs(text):
    text = re.sub(r"(?ms)^```[^\n]*\n.*?^```\s*$", "", text)
    counts, slugs = {}, set()
    for title in re.findall(r"^#{1,6}\s+(.+?)\s*#*\s*$", text, re.MULTILINE):
        base = re.sub(r"[^\w\- ]", "", title.lower()).replace(" ", "-")
        number = counts.get(base, 0)
        counts[base] = number + 1
        slugs.add(base if number == 0 else f"{base}-{number}")
    return slugs


def main():
    paths = set(ROOT.glob("*.md"))
    for directory in ["docs", "examples", "ci"]:
        paths.update(p for p in (ROOT / directory).rglob("*.md") if ".terraform" not in p.parts)
    errors = []
    for path in sorted(paths):
        text = re.sub(r"(?ms)^```[^\n]*\n.*?^```\s*$", "", path.read_text())
        for target in re.findall(r"\]\(([^\s)]+)\)", text):
            url = urlsplit(target)
            if url.scheme or url.netloc:
                continue
            resolved = (path.parent / unquote(url.path)).resolve() if url.path else path
            if not resolved.is_relative_to(ROOT) or not resolved.is_file():
                errors.append(f"{path.relative_to(ROOT)}: missing local target {target}")
            elif url.fragment and resolved.suffix == ".md" and unquote(url.fragment) not in heading_slugs(resolved.read_text()):
                errors.append(f"{path.relative_to(ROOT)}: missing heading {target}")
    validation = (ROOT / "docs/validation.md").read_text()
    if validation.count("## Current release:") != 1 or validation.count("## Historical provider 0.9.0 evidence") != 1:
        errors.append("docs/validation.md: duplicate or missing release section")
    runs = sum(len(re.findall(r'^run\s+"', p.read_text(), re.MULTILINE)) for p in (ROOT / "examples").glob("*/tests/*.tftest.hcl"))
    reported = re.findall(r"\*\*(\d+) mock Terraform feature tests\*\*", validation)
    if reported != [str(runs)] or f"{runs} mocked Terraform feature tests" not in (ROOT / "README.md").read_text():
        errors.append("README.md/docs/validation.md: recorded Terraform test count differs from source")
    release = re.search(r"## Current release: provider (\d+\.\d+\.\d+)", validation)
    if release is None:
        raise SystemExit("docs/validation.md: missing current provider version")
    receipt = json.loads((ROOT / f"docs/live-runs/provider-{release.group(1)}-receipts.json").read_text())
    for run in receipt["runs"]:
        directory = ROOT / "examples" / run["project"]
        actual = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in directory.glob("*.tf")}
        if actual != run["source_sha256"]:
            errors.append(f"{run['variant']}: live source file set or hashes differ")
        checked = {row["type"] for row in receipt["cleanup"]["checks"] if row["project"] == run["project"]}
        missing = set(run["managed_resource_types"]) - checked
        if missing:
            errors.append(f"{run['variant']}: missing independent cleanup types {sorted(missing)}")
    for stem, extension in [("gateway-provider-catalog", ".txt"), ("gateway-provider-catalog-release", ".txt"),
                            ("gateway-existing-models", ".md")]:
        live_receipt = ROOT / f"docs/live-runs/{stem}-receipt.json"
        if not live_receipt.is_file():
            continue
        evidence = json.loads(live_receipt.read_text())
        for relative, expected_hash in evidence["source_sha256"].items():
            source = ROOT / relative
            if not source.is_file() or hashlib.sha256(source.read_bytes()).hexdigest() != expected_hash:
                errors.append(f"{stem}: live source differs from its captured hash: {relative}")
        transcript = ROOT / f"docs/live-runs/{stem}{extension}"
        if not transcript.is_file() or hashlib.sha256(transcript.read_bytes()).hexdigest() != evidence["transcript_sha256"]:
            errors.append(f"{stem}: live transcript differs from its recorded hash")
    for stem in ["red-team-adapters", "red-team-adapters-release"]:
        adapter_receipt = ROOT / f"docs/live-runs/{stem}-receipt.json"
        if not adapter_receipt.is_file():
            continue
        evidence = json.loads(adapter_receipt.read_text())
        for relative, expected in evidence["source_sha256"].items():
            source = ROOT / relative
            if not source.is_file() or hashlib.sha256(source.read_bytes()).hexdigest() != expected:
                errors.append(f"adapter lesson: recorded source hash differs: {relative}")
        transcript = ROOT / evidence["transcript_path"]
        if not transcript.is_file() or hashlib.sha256(transcript.read_bytes()).hexdigest() != evidence["transcript_sha256"]:
            errors.append("adapter lesson: recorded transcript hash differs")
    cicd_receipt = ROOT / "examples/cicd/forgejo-conjur/live-receipt.json"
    if cicd_receipt.is_file():
        evidence = json.loads(cicd_receipt.read_text())
        for relative, expected in evidence["source_sha256"].items():
            source = ROOT / relative
            if not source.is_file() or hashlib.sha256(source.read_bytes()).hexdigest() != expected:
                errors.append(f"CI/CD harness: recorded helper hash differs: {relative}")
        transcript = ROOT / "examples/cicd/forgejo-conjur/live-run.md"
        if hashlib.sha256(transcript.read_bytes()).hexdigest() != evidence["transcript_sha256"]:
            errors.append("CI/CD harness: recorded transcript hash differs")
    if errors:
        raise SystemExit("\n".join(errors))
    print(f"Checked {len(paths)} Markdown files/heading targets, {runs} mock test runs, and {len(receipt['runs'])} live source hash sets and cleanup type coverage.")


if __name__ == "__main__":
    main()
