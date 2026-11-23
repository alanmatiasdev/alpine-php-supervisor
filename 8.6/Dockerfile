FROM golang:1.27 AS exporter-build

WORKDIR /src
RUN git clone --depth 1 https://github.com/salimd/supervisord_exporter.git .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/supervisord_exporter .

FROM php:8.6-fpm-alpine
LABEL maintainer="Alan Matias <me@alanmatias.dev>"

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN apk update && apk upgrade --no-cache
RUN apk add wget

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# ds 1.x do PECL ainda não compila no PHP 8.6 (XtOffsetOf removido); usa o commit do master com o fix
# amqp fica de fora no 8.6 até o upstream suportar o PHP 8.6 (php-amqp/php-amqp#643)
RUN chmod +x /usr/local/bin/install-php-extensions && \
  install-php-extensions php-ds/ext-ds@6e9d66812b0acb9445c446b8dfb79904e0a9bc13 pdo_pgsql pdo_mysql mysqli pgsql sockets intl bcmath zip gd pcntl grpc protobuf && \
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