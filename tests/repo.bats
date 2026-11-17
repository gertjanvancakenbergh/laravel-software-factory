#!/usr/bin/env bats
# Guards the factory repo itself. Uploading files through the GitHub web UI
# drops the executable bit, which breaks every installed project.
load helpers

SCRIPTS="install.sh factory/checks.sh factory/bin/factory factory/bin/job factory/docker/gate-entrypoint.sh"

@test "scripts are executable in the working tree" {
  local f
  for f in $SCRIPTS; do
    [ -x "$FACTORY_SRC/$f" ] || { echo "not executable: $f"; return 1; }
  done
}

@test "scripts are stored as executable (100755) in git" {
  git -C "$FACTORY_SRC" rev-parse --is-inside-work-tree >/dev/null 2>&1 || skip "not a git checkout"
  local f mode
  for f in $SCRIPTS; do
    mode="$(git -C "$FACTORY_SRC" ls-files -s -- "$f" | cut -d' ' -f1)"
    [ "$mode" = "100755" ] || { echo "$f is $mode in git; run: git update-index --chmod=+x $f"; return 1; }
  done
}

@test "every factory file the README and AGENTS.md name exists" {
  local path count=0
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    count=$((count + 1))
    [ -e "$FACTORY_SRC/$path" ] || { echo "README/AGENTS.md names a missing file: $path"; return 1; }
  done <<PATHS
$(grep -ohE '`(agents|docs/factory|examples|factory|stubs)/[A-Za-z0-9._/-]+\.(md|sh|json)`' \
    "$FACTORY_SRC/README.md" "$FACTORY_SRC/AGENTS.md" | tr -d '`' | sort -u)
PATHS
  [ "$count" -gt 10 ] || { echo "only $count paths found; is the pattern still right?"; return 1; }
}
