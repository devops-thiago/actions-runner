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

## Verify Image Signature

All images are signed with [cosign](https://github.com/sigstore/cosign) and include SLSA provenance attestations.

```bash
cosign verify \
  --certificate-identity-regexp 'https://github\.com/devops-thiago/' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  ghcr.io/devops-thiago/actions-runner:latest
```

## License

[MIT](LICENSE)
