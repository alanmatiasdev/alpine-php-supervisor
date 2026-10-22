#!/usr/bin/env bash
# Usage: smoke-test.sh <image> <dockerfile-dir>
# Fails if the built image is missing the tools and extensions its Dockerfile is expected to ship.
set -euo pipefail

image="$1"
dockerfile="$2/Dockerfile"

run() { docker run --rm --entrypoint "" "$image" "$@"; }

# Base images pinned to php:X.Y.Z-* must really report that PHP version
expected_php=$(sed -nE 's/^FROM php:([0-9]+\.[0-9]+\.[0-9]+)-.*/\1/p' "$dockerfile")
if [[ -n "$expected_php" ]]; then
  actual_php=$(run php -r 'echo PHP_VERSION;')
  if [[ "$expected_php" != "$actual_php" ]]; then
    echo "::error::PHP version: expected '$expected_php', got '$actual_php' ($image)"
    exit 1
  fi
  echo "ok: PHP version = $actual_php"
fi

run supervisord --version
run php-fpm -t

for ext in pcntl sockets intl bcmath zip gd pdo_pgsql pdo_mysql amqp ds; do
  run php -r "exit(extension_loaded('$ext') ? 0 : 1);" || { echo "::error::missing PHP extension: $ext ($image)"; exit 1; }
  echo "ok: extension $ext"
done

if grep -q 'composer' "$dockerfile"; then
  run composer --version --no-ansi
fi

if grep -q 'supervisord_exporter' "$dockerfile"; then
  run test -x /usr/local/bin/supervisord_exporter
  echo "ok: supervisord_exporter"
fi

# gRPC comes from the php-grpc base image
if grep -q 'php-grpc' "$dockerfile"; then
  for ext in grpc protobuf; do
    run php -r "exit(extension_loaded('$ext') ? 0 : 1);" || { echo "::error::missing PHP extension: $ext ($image)"; exit 1; }
    echo "ok: extension $ext"
  done
fi
