# Self-Hosted GitHub Actions Runner

[![CI](https://github.com/devops-thiago/actions-runner/actions/workflows/ci.yml/badge.svg)](https://github.com/devops-thiago/actions-runner/actions/workflows/ci.yml)
[![Release](https://github.com/devops-thiago/actions-runner/actions/workflows/release.yml/badge.svg)](https://github.com/devops-thiago/actions-runner/actions/workflows/release.yml)

Dockerized, self-hosted GitHub Actions runner. Multi-arch (`amd64`, `arm64`, `arm/v7`), signed, and published to GHCR.

## Quick Start

1. Copy the example env file and fill in your values:

```bash
cp .env.example .env
```

2. Configure the required variables in `.env`:

| Variable | Required | Default | Description |
|---|---|---|---|
| `GH_TOKEN` | Yes | — | GitHub PAT with `repo` and `admin:org` scopes |
| `REPO_OWNER` | Yes | — | GitHub repository owner |
| `REPO_NAME` | Yes | — | GitHub repository name |
| `RUNNER_VERSION` | No | `2.334.0` | Actions runner version |
| `RUNNER_ARCH` | No | `x64` | Runner architecture (`x64`, `arm64`) |
| `RUNNER_NAME_PREFIX` | No | `gh-runner` | Runner name prefix (suffixed with container hostname) |
| `RUNNER_LABELS` | No | `self-hosted,linux` | Comma-separated runner labels |
| `RUNNER_EPHEMERAL` | No | `false` | Set to `true` for single-job ephemeral runners |

3. Start the runners:

```bash
docker compose up -d --build
```

## Scaling

Adjust the number of runners by changing the `replicas` value in `docker-compose.yml` or via the CLI:

```bash
docker compose up -d --scale runner=5
```

## Architecture

Each container:
- Registers as a **persistent** runner by default, or as **ephemeral** (single job, then re-registers) when `RUNNER_EPHEMERAL=true`
- Fetches its own registration token from the GitHub API using `GH_TOKEN`
- Deregisters cleanly on shutdown via `SIGTERM`/`SIGINT`

The runner tarball SHA-256 checksum is verified dynamically against the GitHub release notes at build time.

## CI/CD

- **On push / PR**: Dockerfile lint (hadolint), multi-arch build validation, Trivy vulnerability scan
- **On merge to main**: Multi-arch build → push to `ghcr.io/devops-thiago/actions-runner:sha-<hash>` + `main`
- **On tag (`v*`)**: Promote image to version tag + `latest`

All images are **signed with cosign** (keyless/Sigstore) and include **SLSA provenance attestations**.

## Security

- All GitHub Actions are pinned to immutable commit SHAs (not mutable tags)
- Trivy action pinned to `v0.35.0` (SHA-pinned) / binary `v0.72.0` — safe versions post [CVE-2026-33634](https://github.com/aquasecurity/trivy/security/advisories/GHSA-69fq-xp46-6x23) (only `v0.69.4`–`v0.69.6` were compromised)
- Branch protection enforced: PR reviews, status checks, no force pushes
- See [SECURITY.md](SECURITY.md) for the vulnerability reporting policy

### Verify image signature

```bash
cosign verify \
  --certificate-identity-regexp 'https://github\.com/devops-thiago/' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  ghcr.io/devops-thiago/actions-runner:latest
```

### Repo hardening

After the initial push, run:

```bash
bash scripts/harden-repo.sh
```

This enables branch protection, vulnerability alerts, automated security fixes, and secret scanning with push protection.
