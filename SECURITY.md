# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| latest  | ✅        |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do not** open a public GitHub issue.
2. Use [GitHub's private vulnerability reporting](https://github.com/devops-thiago/actions-runner/security/advisories/new) to submit a report.
3. Include steps to reproduce, impact assessment, and any suggested fixes.

We will acknowledge receipt within 48 hours and aim to release a fix within 7 days for critical issues.

## Security Practices

- All CI/CD actions are **pinned to immutable commit SHAs** — never mutable tags.
- Container images are **signed with cosign** (keyless/Sigstore) and include **SLSA provenance attestations**.
- Images are scanned with **Trivy** (pinned to known-safe versions post [CVE-2026-33634](https://github.com/aquasecurity/trivy/security/advisories/GHSA-69fq-xp46-6x23)).
- Multi-arch images are built and published to GitHub Container Registry (GHCR).

## Verifying Image Signatures

```bash
cosign verify \
  --certificate-identity-regexp 'https://github\.com/devops-thiago/' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  ghcr.io/devops-thiago/actions-runner:latest
```
