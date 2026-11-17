#!/usr/bin/env bash
# Install or upgrade the Laravel Software Factory into a Laravel project.
#
#   ./install.sh <laravel-project-dir> [--install-deps] [--dry-run]
#
# Never overwrites project files. Factory-owned files (agents/, factory/bin,
# docs/factory/, the gate workflow) are updated on re-run; project state
# (factory/config.json, docs/context/, phpstan.neon, architecture tests) is
# only created when missing. package.json, README.md and composer.json are
# never touched (composer.json only via --install-deps).
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
MARKER="<!-- laravel-software-factory -->"
DRY=0
DEPS=0
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --install-deps) DEPS=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "unknown option $arg" >&2; exit 1 ;;
    *) TARGET="$arg" ;;
  esac
done

[ -n "$TARGET" ] || { echo "usage: ./install.sh <laravel-project-dir> [--install-deps] [--dry-run]" >&2; exit 1; }
[ -d "$TARGET" ] || { echo "error: $TARGET is not a directory" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" != "$SRC" ] || { echo "error: target must be a Laravel project, not the factory repo" >&2; exit 1; }
if [ ! -f "$TARGET/artisan" ] || [ ! -f "$TARGET/composer.json" ]; then
  echo "error: $TARGET does not look like a Laravel project (no artisan/composer.json)" >&2
  exit 1
fi
command -v jq >/dev/null 2>&1 || echo "warning: jq is not installed; factory scripts need it at runtime" >&2

UPDATED=0; CREATED=0; SKIPPED=0

put() {
  # put <src-rel> <dest-rel> <owned|state>
  local src="$SRC/$1" dest="$TARGET/$2" kind="$3"
  if [ -e "$dest" ]; then
    if [ "$kind" = state ]; then
      SKIPPED=$((SKIPPED + 1)); return 0
    fi
    if cmp -s "$src" "$dest"; then return 0; fi
    echo "  update  $2"; UPDATED=$((UPDATED + 1))
  else
    echo "  create  $2"; CREATED=$((CREATED + 1))
  fi
  [ "$DRY" -eq 1 ] && return 0
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  if [ -x "$src" ]; then chmod +x "$dest"; fi
}

put_tree() {
  # put_tree <src-dir-rel> <dest-dir-rel> <owned|state>
  local f rel
  while IFS= read -r f; do
    rel="${f#"$SRC/$1"/}"
    put "$1/$rel" "$2/$rel" "$3"
  done < <(find "$SRC/$1" -type f ! -name '.DS_Store' | sort)
}

echo "Installing Laravel Software Factory into $TARGET"
[ "$DRY" -eq 1 ] && echo "(dry run: nothing is written)"

# Factory-owned: safe to update on every install.
put_tree agents agents owned
put_tree factory/bin factory/bin owned
put_tree factory/lib factory/lib owned
put_tree factory/docker factory/docker owned
put factory/checks.sh factory/checks.sh owned
put_tree docs/factory docs/factory owned
put_tree examples docs/factory/examples owned
put stubs/.github/workflows/factory-gate.yml .github/workflows/factory-gate.yml owned
put AGENTS.md docs/factory/AGENTS.md owned

# Project state: created once, then owned by the project.
put factory/config.json factory/config.json state
put_tree docs/context docs/context state
put stubs/tests/Architecture/ConventionsTest.php tests/Architecture/ConventionsTest.php state

if [ -f "$TARGET/phpstan.neon" ] || [ -f "$TARGET/phpstan.neon.dist" ]; then
  if ! grep -q 'larastan/extension.neon' "$TARGET"/phpstan.neon* 2>/dev/null; then
    echo "  note    existing phpstan config kept; add 'vendor/larastan/larastan/extension.neon' to its includes"
  fi
else
  put stubs/phpstan.neon phpstan.neon state
fi

# AGENTS.md: agents read it from the project root.
if [ ! -f "$TARGET/AGENTS.md" ]; then
  put AGENTS.md AGENTS.md state
elif head -1 "$TARGET/AGENTS.md" | grep -qF "$MARKER"; then
  put AGENTS.md AGENTS.md owned
elif ! grep -qF "$MARKER" "$TARGET/AGENTS.md"; then
  echo "  append  AGENTS.md (pointer to docs/factory/AGENTS.md)"
  if [ "$DRY" -eq 0 ]; then
    {
      echo ""
      echo "$MARKER"
      echo "## Laravel Software Factory"
      echo ""
      echo "This project uses the Laravel Software Factory. Every agent must also follow"
      echo "docs/factory/AGENTS.md; if the two files conflict, ask the human."
    } >> "$TARGET/AGENTS.md"
  fi
fi

# .gitignore entries for generated files.
for line in "docs/context/dashboard.html" "docs/context/jobs/.lock" "docs/context/jobs/.tmp.*" "docs/context/jobs/.gate-*.json"; do
  if ! grep -qxF "$line" "$TARGET/.gitignore" 2>/dev/null; then
    echo "  append  .gitignore: $line"
    [ "$DRY" -eq 1 ] || echo "$line" >> "$TARGET/.gitignore"
  fi
done

if [ "$DEPS" -eq 1 ]; then
  echo "Installing dev dependencies with composer"
  if [ "$DRY" -eq 0 ]; then
    (cd "$TARGET" && composer require --dev --no-interaction --with-all-dependencies \
      pestphp/pest pestphp/pest-plugin-laravel larastan/larastan laravel/pao)
  fi
else
  echo ""
  echo "Dev dependencies (run once, or re-run with --install-deps):"
  echo "  composer require --dev --with-all-dependencies pestphp/pest pestphp/pest-plugin-laravel larastan/larastan laravel/pao"
fi

if [ ! -f "$TARGET/routes/api.php" ]; then
  echo ""
  echo "Note: routes/api.php is missing. Laravel 11+ needs 'php artisan install:api' before API"
  echo "routes load; the gate fails until it exists (or set gate.api to \"off\")."
fi

echo ""
echo "Done: $CREATED created, $UPDATED updated, $SKIPPED project files kept."
echo "Next: run ./factory/bin/factory doctor, then require the 'Deterministic Gate' check on main."
