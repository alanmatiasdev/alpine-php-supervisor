# Security Policy

## Reporting a vulnerability

Please report vulnerabilities privately through GitHub's
[private vulnerability reporting](https://github.com/alanmatiasdev/alpine-php-supervisor/security/advisories/new).
Do not open a public issue for security problems.

Include the affected image tag, how to reproduce the problem and its impact. You can expect an
acknowledgement within a few days.

## Supported images

Only the images published from `main` are supported: PHP 8.1, 8.2, 8.3 and 8.4 (`8.1`, `8.2`, `8.3`, `8.4` and `latest`).

## How the images are protected

- Every image is linted with hadolint, smoke-tested and scanned with Trivy before it is published;
  HIGH and CRITICAL vulnerabilities that have a fix block the publish.
- Images are rebuilt weekly to pick up base image patches.
- Published images carry an SBOM and provenance attestation and are signed with cosign (keyless).
- Dependencies (base images and GitHub Actions) are tracked by Dependabot, and workflows are
  audited with zizmor.
