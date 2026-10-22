# alpine-php-supervisor

PHP-FPM on Alpine with [Supervisor](http://supervisord.org), one directory per PHP version.

| Directory | Base image                             | Notes                                                                      |
| --------- | -------------------------------------- | -------------------------------------------------------------------------- |
| `8.1/`    | `php:8.1-fpm-alpine`                   | Legacy. Composer, common extensions, Supervisor.                           |
| `8.2/`    | `alanmatias/php-grpc:8.2-fpm-alpine`   | gRPC/Protobuf from the base image, `php.ini` tuning, Supervisor exporter.  |

Both images run `supervisord` as the entrypoint with `/etc/supervisor/conf.d/supervisord.conf`, which you
must provide (mount or `COPY` it in a derived image). PHP-FPM listens on port `9001` instead of `9000`.

## Building

```bash
docker build -t alpine-php-supervisor:8.2 8.2
```

The `8.2` image exposes the Supervisor metrics exporter on port `9876`.

## Security

- Every image is linted, smoke-tested and scanned with [Trivy](https://trivy.dev) before it is published. Fixable `HIGH` and `CRITICAL` vulnerabilities block the publish.
- All images are rebuilt every Monday so base image patches reach the published tags.
- Published images include an SBOM and a provenance attestation, and are signed with [cosign](https://github.com/sigstore/cosign) (keyless). To verify an image:

```bash
cosign verify alandealmeida/alpine-php-supervisor:8.2 \
  --certificate-identity-regexp '^https://github.com/alanmatiasdev/alpine-php-supervisor/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

To report a vulnerability, see [SECURITY.md](SECURITY.md).
