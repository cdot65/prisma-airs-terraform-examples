#!/usr/bin/env python3
"""Check the unreleased catalog lesson against a local provider, without API access."""

import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--provider-dir", required=True, type=Path,
                        help="Directory containing the catalog-capable terraform-provider-prisma-airs binary.")
    args = parser.parse_args()
    provider_dir = args.provider_dir.resolve()
    if not (provider_dir / "terraform-provider-prisma-airs").is_file():
        parser.error("Build the provider before running this check.")
    root = Path(__file__).resolve().parents[1]
    example = root / "examples/ai-gateway/provider-catalog"
    environment = {key: value for key, value in os.environ.items()
                   if not key.startswith(("PANW_", "TF_VAR_", "TF_LOG"))}
    with tempfile.TemporaryDirectory(prefix="airs-catalog-check-") as directory:
        config = Path(directory) / "dev.tfrc"
        config.write_text('provider_installation {\n  dev_overrides {\n    "cdot65/prisma-airs" = '
                          + json.dumps(str(provider_dir)) + '\n  }\n  direct {}\n}\n')
        environment.update(TF_CLI_CONFIG_FILE=str(config), TF_IN_AUTOMATION="1")
        def run(*arguments, **kwargs):
            return subprocess.run(["terraform", *arguments], cwd=example,
                                  env=environment, check=True, **kwargs)
        run("fmt", "-check", "-recursive")
        template = (example / "terraform.tfvars.example").read_text()
        if run("fmt", "-", input=template, capture_output=True, text=True).stdout != template:
            raise SystemExit("Format the catalog lesson's sample inputs.")
        run("validate", "-no-color")
        run("test", "-no-color")
    print("Catalog lesson validated with a local provider and no live credentials.")


if __name__ == "__main__":
    main()
