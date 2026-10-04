#!/usr/bin/env python3
"""Check the adapter lesson using the Registry provider or a local build, without API access."""

import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--provider-dir", type=Path,
                        help="Directory containing the adapter-capable terraform-provider-prisma-airs binary.")
    args = parser.parse_args()
    provider_dir = args.provider_dir.resolve() if args.provider_dir else None
    if provider_dir and not (provider_dir / "terraform-provider-prisma-airs").is_file():
        parser.error("Build the provider before running this check.")
    root = Path(__file__).resolve().parents[1]
    example = root / "examples/ai-red-teaming/adapters"
    environment = {key: value for key, value in os.environ.items()
                   if not key.startswith(("PANW_", "TF_VAR_", "TF_LOG"))}
    with tempfile.TemporaryDirectory(prefix="airs-adapters-check-") as directory:
        config = Path(directory) / "dev.tfrc"
        if provider_dir:
            config.write_text('provider_installation {\n  dev_overrides {\n    "cdot65/prisma-airs" = '
                              + json.dumps(str(provider_dir)) + '\n  }\n  direct {}\n}\n')
        else:
            config.write_text('provider_installation {\n  direct {}\n}\n')
        environment.update(TF_CLI_CONFIG_FILE=str(config), TF_IN_AUTOMATION="1")
        def run(*arguments, **kwargs):
            return subprocess.run(["terraform", *arguments], cwd=example,
                                  env=environment, check=True, **kwargs)
        run("fmt", "-check", "-recursive")
        template = (example / "terraform.tfvars.example").read_text()
        if run("fmt", "-", input=template, capture_output=True, text=True).stdout != template:
            raise SystemExit("Format the adapter lesson's sample inputs.")
        if not provider_dir:
            run("init", "-backend=false", "-input=false", "-no-color")
        run("validate", "-no-color")
    print("Adapter lesson validated without live credentials.")


if __name__ == "__main__":
    main()
