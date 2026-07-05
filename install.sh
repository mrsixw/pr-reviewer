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

for dir in "${SKILL_DIRS[@]}"; do
  mkdir -p "$dir"
  link="$dir/$SKILL_NAME"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "SKIP  $link exists and is not a symlink — resolve manually" >&2
    continue
  fi
  ln -sfn "$REPO_DIR" "$link"
  echo "OK    $link -> $REPO_DIR"
done
