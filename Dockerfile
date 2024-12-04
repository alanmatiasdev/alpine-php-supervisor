FROM php:8.2-fpm-alpine
LABEL maintainer="Alan Matias <falecomigo@alandealmeida.com>"

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apk update
RUN apk add wget

COPY --from=composer /usr/bin/composer /usr/bin/composer

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
  install-php-extensions ds pdo_pgsql pdo_mysql mysqli amqp pgsql sockets intl bcmath zip gd && \
  mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini && \
  sed -i 's/memory_limit = 128M/memory_limit = 512M/' $PHP_INI_DIR/php.ini && \
  sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/' $PHP_INI_DIR/php.ini && \
  sed -i 's/post_max_size = 8M/post_max_size = 512M/' $PHP_INI_DIR/php.ini

# ALTERA PORTA DEFAULT DO PHP-FPM
RUN sed -i 's/9000/9001/' /usr/local/etc/php-fpm.d/zz-docker.conf

# CONFIGURA O SUPERVISOR
RUN apk add supervisor
# Make supervisor log directory
RUN mkdir -p /var/log/supervisor

WORKDIR /var/www/html

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]