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
