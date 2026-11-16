#!/usr/bin/env bash
# Deterministic gate. Exit non-zero on failure.
set -euo pipefail

echo "=== Running deterministic gate ==="

if [ -f vendor/bin/pest ]; then
  vendor/bin/pest --parallel || exit 1
fi

if [ -f vendor/bin/pint ]; then
  vendor/bin/pint --test || exit 1
fi

if [ -f vendor/bin/phpstan ]; then
  vendor/bin/phpstan analyse --memory-limit=2G || exit 1
fi

# Frontend (optional)
if [ -f package.json ]; then
  if jq -e '.scripts.typecheck' package.json >/dev/null 2>&1; then
    npm run typecheck || exit 1
  fi
  if jq -e '.scripts.lint' package.json >/dev/null 2>&1; then
    npm run lint || exit 1
  fi
fi

echo "=== Gate passed ==="
