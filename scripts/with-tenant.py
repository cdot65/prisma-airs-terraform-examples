#!/usr/bin/env python3
"""Run a command with credentials from a registered AIRS CLI tenant."""

import json
import os
from pathlib import Path
import subprocess
import sys


def main():
    if len(sys.argv) < 3:
        sys.exit("Usage: python3 scripts/with-tenant.py TENANT COMMAND [ARGS...]")
    tenant, command = sys.argv[1], sys.argv[2:]
    registered = subprocess.run(
        ["airs", "cli", "tenant", "list", "--output", "json"],
        capture_output=True, text=True, check=True,
    )
    matches = [item for item in json.loads(registered.stdout) if item["name"] == tenant]
    if len(matches) != 1:
        sys.exit("Expected exactly one registered tenant with that name.")
    config = json.loads(Path(matches[0]["configPath"]).read_text())
    environment = os.environ.copy()
    fields = {
        "PANW_MGMT_CLIENT_ID": "mgmtClientId",
        "PANW_MGMT_CLIENT_SECRET": "mgmtClientSecret",
        "PANW_MGMT_TSG_ID": "mgmtTsgId",
    }
    for variable, field in fields.items():
        value = config.get(field)
        if not isinstance(value, str) or not value.strip():
            sys.exit(f"Tenant configuration is missing {field}.")
        environment[variable] = value
    # Provider debug logs can contain connection credentials.
    for key in ("TF_LOG", "TF_LOG_PROVIDER", "TF_LOG_PATH"):
        environment.pop(key, None)
    os.execvpe(command[0], command, environment)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError):
        sys.exit("Could not read the AIRS CLI tenant registration/configuration.")
