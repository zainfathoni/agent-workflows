#!/usr/bin/env bash
# Symlink shared skills into the global agent skills directory.

set -euo pipefail

SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ROOT=${AGENT_SKILLS_DIR:-$HOME/.agents/skills}

usage() {
  printf 'Usage: skills/install.sh\n'
  printf '\n'
  printf 'Environment:\n'
  printf '  AGENT_SKILLS_DIR   default: ~/.agents/skills\n'
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

mkdir -p "$TARGET_ROOT"

installed=0

for skill_dir in "$SKILLS_ROOT"/*; do
  if [ ! -d "$skill_dir" ]; then
    continue
  fi

  skill_name=$(basename "$skill_dir")
  if [ "$skill_name" = "README.md" ]; then
    continue
  fi

  if [ ! -f "$skill_dir/SKILL.md" ]; then
    continue
  fi

  target="$TARGET_ROOT/$skill_name"

  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    printf 'Refusing to overwrite non-symlink skill target: %s\n' "$target" >&2
    printf 'Move it aside or remove it, then rerun the installer.\n' >&2
    exit 1
  fi

  ln -s "$skill_dir" "$target"
  printf 'Installed %s -> %s\n' "$skill_name" "$skill_dir"
  installed=$((installed + 1))
done

printf 'Installed %s shared skill(s) into %s\n' "$installed" "$TARGET_ROOT"
