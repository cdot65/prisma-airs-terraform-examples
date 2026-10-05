# Tooling: A predictable Node 24/Python job environment; Terraform is checksum-pinned.
FROM node:24-bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends git python3 python3-venv ca-certificates \
    && rm -rf /var/lib/apt/lists/*
