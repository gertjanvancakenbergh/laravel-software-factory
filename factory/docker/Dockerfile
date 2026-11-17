# Gate runner for machines (or sandboxes) without PHP/Composer/jq/Node.
# Used by: ./factory/bin/factory gate <job-id> --docker
FROM php:8.3-cli-bookworm

RUN apt-get update \
 && apt-get install -y --no-install-recommends git unzip jq nodejs npm libzip-dev libicu-dev \
 && docker-php-ext-install pdo_mysql zip intl bcmath \
 && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
ENTRYPOINT ["bash", "factory/docker/gate-entrypoint.sh"]
