#!/usr/bin/env bash
# Symlink this repo into every coding agent's global skills directory.
# Idempotent: safe to re-run after moving the repo or adding a new agent dir.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="pr-reviewer"

# One entry per agent: Claude Code, agy (Antigravity CLI).
SKILL_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.gemini/config/skills"
)

# Targets that ended up pointing somewhere other than this repo. Collected
# rather than reported inline: the per-directory output scrolls past, and the
# thing a caller needs is one summary at the end plus a non-zero status.
UNRESOLVED=()

# Resolve a path to its real location. Used to compare what a link actually
# points at against this repo, so a symlinked $HOME or a relative link cannot
# read as a different install.
resolve_path() {
  local target="$1"
  if [ -d "$target" ]; then
    (cd -P "$target" 2>/dev/null && pwd) || printf '%s' "$target"
  else
    printf '%s' "$target"
  fi
}

for dir in "${SKILL_DIRS[@]}"; do
  mkdir -p "$dir"
  link="$dir/$SKILL_NAME"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "SKIP  $link exists and is not a symlink — resolve manually" >&2
    UNRESOLVED+=("$link (not a symlink)")
    continue
  fi
  ln -sfn "$REPO_DIR" "$link"

  # Verify rather than assume. `ln -sfn` can succeed and still leave a link
  # that resolves elsewhere — most often when $link is a symlink to a
  # *directory*, where the new link lands inside it instead of replacing it.
  # An install that reports success while the agent loads a different skill is
  # the whole bug this guards against.
  actual="$(resolve_path "$link")"
  expected="$(resolve_path "$REPO_DIR")"
  if [ "$actual" != "$expected" ]; then
    echo "FAIL  $link -> $actual (expected $expected)" >&2
    UNRESOLVED+=("$link -> $actual")
    continue
  fi
  echo "OK    $link -> $REPO_DIR"
done

if [ ${#UNRESOLVED[@]} -gt 0 ]; then
  echo >&2
  if [ ${#UNRESOLVED[@]} -eq 1 ]; then
    echo "❌ 1 skill directory does not point at this repo:" >&2
  else
    echo "❌ ${#UNRESOLVED[@]} skill directories do not point at this repo:" >&2
  fi
  for entry in "${UNRESOLVED[@]}"; do
    echo "     $entry" >&2
  done
  echo >&2
  echo "   Those agents will load a different $SKILL_NAME, so edits made here" >&2
  echo "   will appear to have no effect. Remove or rename each path above," >&2
  echo "   then re-run this installer." >&2
  exit 1
fi
