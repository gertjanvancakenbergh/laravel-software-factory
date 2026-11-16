#!/usr/bin/env bash
# Shared bats setup: a throwaway project with the factory installed.
# Variables here are consumed by the .bats files; stubs are intentionally single-quoted.
# shellcheck disable=SC2034,SC2016

FACTORY_SRC="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"

make_project() {
  PROJECT="$(mktemp -d)"
  mkdir -p "$PROJECT/factory" "$PROJECT/docs/context/jobs"
  cp -R "$FACTORY_SRC/factory/bin" "$FACTORY_SRC/factory/lib" "$PROJECT/factory/"
  cp "$FACTORY_SRC/factory/checks.sh" "$FACTORY_SRC/factory/config.json" "$PROJECT/factory/"
  cp "$FACTORY_SRC/docs/context/jobs/README.md" "$PROJECT/docs/context/jobs/"
  export FACTORY_ROOT="$PROJECT"
  JOB="$PROJECT/factory/bin/job"
  FACTORY="$PROJECT/factory/bin/factory"
  CHECKS="$PROJECT/factory/checks.sh"
}

# A fake Laravel project whose tools succeed (or fail when told to).
make_fake_laravel() {
  cd "$PROJECT" || return 1
  echo '{}' > composer.json
  touch artisan phpstan.neon
  mkdir -p vendor/bin tests/Architecture bin
  echo '<?php' > tests/Architecture/ConventionsTest.php
  local tool
  for tool in pest pint phpstan; do
    printf '#!/bin/sh\necho "%s $*" >> "%s/calls.log"\nexit ${FAIL_%s:-0}\n' "$tool" "$PROJECT" "$tool" > "vendor/bin/$tool"
    chmod +x "vendor/bin/$tool"
  done
  printf '#!/bin/sh\necho "composer $*" >> "%s/calls.log"\nexit ${FAIL_composer:-0}\n' "$PROJECT" > bin/composer
  printf '#!/bin/sh\necho "npm $*" >> "%s/calls.log"\nexit ${FAIL_npm:-0}\n' "$PROJECT" > bin/npm
  chmod +x bin/composer bin/npm
  export PATH="$PROJECT/bin:$PATH"
}

cleanup_project() {
  [ -n "${PROJECT:-}" ] && rm -rf "$PROJECT"
  unset FACTORY_ROOT
}
