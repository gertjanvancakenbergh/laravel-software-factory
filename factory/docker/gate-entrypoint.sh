#!/usr/bin/env bash
# Runs inside the gate container with the project mounted at /app.
# vendor/ and node_modules/ are container-only volumes, so host installs are untouched.
set -euo pipefail
git config --global --add safe.directory /app

composer install --no-interaction --no-progress --prefer-dist
if [ -f package.json ]; then npm ci --no-audit --no-fund; fi

# Tests use phpunit.xml's database settings (SQLite in memory by default).
# The app key only needs to exist for the process; nothing is written to .env.
if [ -z "${APP_KEY:-}" ]; then
  APP_KEY="base64:$(head -c 32 /dev/urandom | base64)"
  export APP_KEY
fi

exec bash factory/checks.sh
