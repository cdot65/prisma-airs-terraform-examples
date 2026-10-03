#!/usr/bin/env python3
"""Validate every public example without tenant credentials or remote writes."""

from pathlib import Path
import subprocess
import sys


def main():
    root = Path(__file__).resolve().parents[1]
    subprocess.run(["terraform", "fmt", "-check", "-recursive"], cwd=root, check=True)
    for example in sorted((root / "examples").iterdir()):
        if not (example / "main.tf").is_file():
            continue
        print(f"Validating {example.name}", flush=True)
        subprocess.run(
            ["terraform", "init", "-backend=false", "-input=false", "-lockfile=readonly", "-no-color"],
            cwd=example, check=True,
        )
        subprocess.run(["terraform", "validate", "-no-color"], cwd=example, check=True)


if __name__ == "__main__":
    try:
        main()
    except FileNotFoundError:
        sys.exit("Install Terraform and put it on PATH.")
    except subprocess.CalledProcessError as error:
        sys.exit(error.returncode)
