#!/usr/bin/env python3
"""Validate every public example without tenant credentials or remote writes."""

from pathlib import Path
import os
import tempfile
import subprocess
import sys


def main():
    root = Path(__file__).resolve().parents[1]
    environment = {key: value for key, value in os.environ.items()
                   if not key.startswith(("PANW_", "TF_VAR_", "TF_LOG"))}
    with tempfile.TemporaryDirectory(prefix="airs-examples-validate-") as directory:
        config = Path(directory) / "direct.tfrc"
        config.write_text("provider_installation {\n  direct {}\n}\n")
        environment["TF_CLI_CONFIG_FILE"] = str(config)
        subprocess.run(["terraform", "fmt", "-check", "-recursive"], cwd=root, env=environment, check=True)
        for template in sorted((root / "examples").glob("*/terraform.tfvars.example")):
            formatted = subprocess.run(["terraform", "fmt", "-"], input=template.read_text(), env=environment,
                                       capture_output=True, text=True, check=True)
            if formatted.stdout != template.read_text():
                sys.exit(f"Format the sample inputs: {template.relative_to(root)}")
        for example in sorted((root / "examples").iterdir()):
            if not (example / "main.tf").is_file():
                continue
            print(f"Validating {example.name}", flush=True)
            subprocess.run(["terraform", "init", "-backend=false", "-input=false", "-lockfile=readonly", "-no-color"],
                           cwd=example, env=environment, check=True)
            subprocess.run(["terraform", "validate", "-no-color"], cwd=example, env=environment, check=True)
            subprocess.run(["terraform", "test", "-no-color"], cwd=example, env=environment, check=True)
        subprocess.run([sys.executable, "scripts/coverage.py"], cwd=root, env=environment, check=True)
        subprocess.run([sys.executable, "-m", "unittest", "discover", "-s", "tests"], cwd=root, env=environment, check=True)


if __name__ == "__main__":
    try:
        main()
    except FileNotFoundError:
        sys.exit("Install Terraform and put it on PATH.")
    except subprocess.CalledProcessError as error:
        sys.exit(error.returncode)
