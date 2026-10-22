FROM golang:1.22 AS exporter-build

WORKDIR /src
RUN git clone --depth 1 https://github.com/salimd/supervisord_exporter.git .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/supervisord_exporter .

FROM alanmatias/php-grpc:8.2-fpm-alpine
LABEL maintainer="Alan Matias <me@alanmatias.dev>"

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apk update
RUN apk add wget

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
  install-php-extensions ds pdo_pgsql pdo_mysql mysqli amqp pgsql sockets intl bcmath zip gd pcntl && \
  mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini && \
  sed -i "s/memory_limit = 128M/memory_limit = 1024M/" $PHP_INI_DIR/php.ini && \
  sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/' $PHP_INI_DIR/php.ini && \
  sed -i 's/post_max_size = 8M/post_max_size = 512M/' $PHP_INI_DIR/php.ini

# ALTERA PORTA DEFAULT DO PHP-FPM
RUN sed -i 's/9000/9001/' /usr/local/etc/php-fpm.d/zz-docker.conf

# CONFIGURA O SUPERVISOR
RUN apk add supervisor
# Make supervisor log directory
RUN mkdir -p /var/log/supervisor

COPY --from=exporter-build /out/supervisord_exporter /usr/local/bin/supervisord_exporter
RUN chmod +x /usr/local/bin/supervisord_exporter

WORKDIR /var/www/html

EXPOSE 9876

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]