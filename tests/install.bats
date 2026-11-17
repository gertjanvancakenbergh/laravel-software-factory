#!/usr/bin/env bats
load helpers

setup() {
  TARGET="$(mktemp -d)"
  touch "$TARGET/artisan"
  echo '{"name":"laravel/laravel"}' > "$TARGET/composer.json"
  echo '{"scripts":{"build":"vite build","dev":"vite"}}' > "$TARGET/package.json"
  echo "# My app" > "$TARGET/README.md"
}
teardown() { rm -rf "$TARGET"; }

@test "refuses a directory that is not a Laravel project" {
  rm "$TARGET/artisan"
  run "$FACTORY_SRC/install.sh" "$TARGET"
  [ "$status" -ne 0 ]
}

@test "never touches package.json, README.md or composer.json" {
  before="$(cat "$TARGET/package.json" "$TARGET/README.md" "$TARGET/composer.json")"
  run "$FACTORY_SRC/install.sh" "$TARGET"
  [ "$status" -eq 0 ]
  [ "$(cat "$TARGET/package.json" "$TARGET/README.md" "$TARGET/composer.json")" = "$before" ]
}

@test "installs the factory with executable scripts" {
  "$FACTORY_SRC/install.sh" "$TARGET"
  [ -x "$TARGET/factory/bin/job" ]
  [ -x "$TARGET/factory/checks.sh" ]
  [ -f "$TARGET/.github/workflows/factory-gate.yml" ]
  [ -f "$TARGET/tests/Architecture/ConventionsTest.php" ]
  grep -q larastan "$TARGET/phpstan.neon"
  [ ! -e "$TARGET/tests/job.bats" ]
  [ ! -e "$TARGET/install.sh" ]
}

@test "keeps an existing phpstan.neon and project state on re-install" {
  echo "parameters: {level: 9}" > "$TARGET/phpstan.neon"
  "$FACTORY_SRC/install.sh" "$TARGET"
  [ "$(cat "$TARGET/phpstan.neon")" = "parameters: {level: 9}" ]
  echo "custom" > "$TARGET/docs/context/domain.md"
  jq '.mode = "auto"' "$TARGET/factory/config.json" > "$TARGET/c" && mv "$TARGET/c" "$TARGET/factory/config.json"
  "$FACTORY_SRC/install.sh" "$TARGET"
  [ "$(cat "$TARGET/docs/context/domain.md")" = "custom" ]
  [ "$(jq -r .mode "$TARGET/factory/config.json")" = "auto" ]
}

@test "appends a pointer to an existing AGENTS.md exactly once" {
  echo "# Our agent rules" > "$TARGET/AGENTS.md"
  "$FACTORY_SRC/install.sh" "$TARGET"
  "$FACTORY_SRC/install.sh" "$TARGET"
  head -1 "$TARGET/AGENTS.md" | grep -q "Our agent rules"
  [ "$(grep -c 'laravel-software-factory' "$TARGET/AGENTS.md")" -eq 1 ]
  [ -f "$TARGET/docs/factory/AGENTS.md" ]
}

@test "re-install is idempotent" {
  "$FACTORY_SRC/install.sh" "$TARGET"
  run "$FACTORY_SRC/install.sh" "$TARGET"
  [[ "$output" == *"0 created, 0 updated"* ]]
  [ "$(grep -c 'docs/context/dashboard.html' "$TARGET/.gitignore")" -eq 1 ]
}

@test "dry run writes nothing" {
  run "$FACTORY_SRC/install.sh" "$TARGET" --dry-run
  [ "$status" -eq 0 ]
  [ ! -e "$TARGET/factory" ]
}

@test "warns when routes/api.php is missing and installs the docker runner" {
  run "$FACTORY_SRC/install.sh" "$TARGET"
  [[ "$output" == *"php artisan install:api"* ]]
  [ -x "$TARGET/factory/docker/gate-entrypoint.sh" ]
  mkdir -p "$TARGET/routes" && touch "$TARGET/routes/api.php"
  run "$FACTORY_SRC/install.sh" "$TARGET"
  [[ "$output" != *"install:api"* ]]
}
