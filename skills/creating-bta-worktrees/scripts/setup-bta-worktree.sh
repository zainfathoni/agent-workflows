#!/usr/bin/env bash
# Standardize local BookThatApp sibling worktrees.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: setup-bta-worktree.sh [options] <worktree> [<worktree> ...]

Options:
  --canonical PATH   Canonical BookThatApp worktree. Default: current repo root, otherwise ../bookthatapp
  --notes-root PATH  BookThatApp claude-notes project root. Default: resolved from canonical .claude symlink
  -h, --help         Show this help.

Refreshes shared Claude/notes symlinks and installs Docker-safe local runtime
files as hard links or copies. Real per-worktree runtime files are skipped.
USAGE
}

default_canonical="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$default_canonical" ]; then
  default_canonical="$(cd "$default_canonical" && pwd)"
else
  default_canonical="$(cd ../bookthatapp 2>/dev/null && pwd || true)"
fi

canonical="${BTA_CANONICAL_WORKTREE:-$default_canonical}"
notes_root="${BTA_NOTES_ROOT:-}"
worktrees=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --canonical)
      if [ "$#" -lt 2 ]; then
        printf 'Missing value for --canonical\n' >&2
        exit 2
      fi
      canonical="$2"
      shift 2
      ;;
    --notes-root)
      if [ "$#" -lt 2 ]; then
        printf 'Missing value for --notes-root\n' >&2
        exit 2
      fi
      notes_root="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [ "$#" -gt 0 ]; do
        worktrees+=("$1")
        shift
      done
      ;;
    -*)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      worktrees+=("$1")
      shift
      ;;
  esac
done

if [ "${#worktrees[@]}" -eq 0 ]; then
  usage >&2
  exit 2
fi

if [ -z "$canonical" ] || [ ! -d "$canonical/.git" ] && ! git -C "$canonical" rev-parse --show-toplevel >/dev/null 2>&1; then
  printf 'Canonical BookThatApp worktree is not valid: %s\n' "${canonical:-<empty>}" >&2
  exit 1
fi

canonical="$(cd "$canonical" && pwd)"

if [ -z "$notes_root" ]; then
  if [ -L "$canonical/.claude" ]; then
    claude_target="$(readlink "$canonical/.claude")"
    case "$claude_target" in
      /*)
        notes_root="$(cd "$(dirname "$claude_target")" && pwd)"
        ;;
      *)
        notes_root="$(cd "$canonical/$(dirname "$claude_target")" && pwd)"
        ;;
    esac
  fi
fi

if [ -z "$notes_root" ] || [ ! -d "$notes_root" ]; then
  printf 'Could not resolve BookThatApp notes root. Pass --notes-root PATH.\n' >&2
  exit 1
fi

notes_root="$(cd "$notes_root" && pwd)"

apply_symlink() {
  local wt="$1"
  local path="$2"
  local target="$3"

  if [ -e "$wt/$path" ] && [ ! -L "$wt/$path" ]; then
    printf 'SKIP real path: %s\n' "$wt/$path"
    return
  fi

  ln -sfn "$target" "$wt/$path"
  printf 'LINK %s -> %s\n' "$wt/$path" "$target"
}

apply_runtime_file() {
  local wt="$1"
  local path="$2"
  local source="$canonical/$path"
  local dest="$wt/$path"

  if [ ! -s "$source" ]; then
    printf 'MISSING canonical runtime file: %s\n' "$source"
    return
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    printf 'SKIP real runtime file: %s\n' "$dest"
  else
    mkdir -p "$(dirname "$dest")"
    rm -f "$dest"
    ln "$source" "$dest" 2>/dev/null || cp -p "$source" "$dest"
    printf 'RUNTIME %s\n' "$dest"
  fi

  if [ -s "$dest" ] && [ ! -L "$dest" ]; then
    printf 'OK runtime file: %s\n' "$dest"
  else
    printf 'BAD runtime file: %s\n' "$dest"
    return 1
  fi
}

for wt in "${worktrees[@]}"; do
  if [ ! -d "$wt" ]; then
    printf 'Missing worktree: %s\n' "$wt" >&2
    exit 1
  fi

  wt="$(cd "$wt" && pwd)"
  printf '## %s\n' "$wt"

  apply_symlink "$wt" .agents "$notes_root/.agents"
  apply_symlink "$wt" .amp "$notes_root/.amp"
  apply_symlink "$wt" .claude "$notes_root/.claude"
  apply_symlink "$wt" .envrc "$notes_root/bookthatapp.envrc"
  apply_symlink "$wt" .mcp.json "$notes_root/bookthatapp.mcp.json"
  apply_symlink "$wt" CLAUDE.md "$notes_root/bookthatapp-CLAUDE.md"
  apply_symlink "$wt" CONTEXT.md "$notes_root/bookthatapp-CONTEXT.md"
  apply_symlink "$wt" PATTERNS.md "$notes_root/bookthatapp-PATTERNS.md"
  apply_symlink "$wt" docs "$notes_root/docs"
  apply_symlink "$wt" scripts "$notes_root/scripts"
  apply_symlink "$wt" teach "$notes_root/teach"

  apply_runtime_file "$wt" .env.development.local
  apply_runtime_file "$wt" docker/development/traefik/bookthatapp.internal.crt
  apply_runtime_file "$wt" docker/development/traefik/bookthatapp.internal.key
  apply_runtime_file "$wt" docker/development/traefik/routes.local.toml
done
