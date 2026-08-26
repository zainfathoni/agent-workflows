#!/usr/bin/env bash
# Create a BookThatApp sibling worktree and apply local setup.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: create-bta-worktree.sh [options] <bta-name>

Arguments:
  <bta-name>         Sibling worktree name, such as bta-debug or bta-teach.

Options:
  --branch BRANCH    New ephemeral branch, matching <type>/trello-<id>/<slug>.
                     Required unless reusing an existing legacy bta/* branch.
  --base BRANCH      Local base branch for a new branch. Default: bta/main
  --canonical PATH   Canonical BookThatApp worktree for runtime files. Default: current repo root
  --notes-root PATH  BookThatApp claude-notes project root. Default: resolved by setup script
  --no-lock          Do not lock the new git worktree.
  -h, --help         Show this help.
USAGE
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
setup_script="$script_dir/setup-bta-worktree.sh"

base_branch="${BTA_WORKTREE_BASE:-bta/main}"
branch="${BTA_WORKTREE_BRANCH:-}"
canonical="${BTA_CANONICAL_WORKTREE:-}"
notes_root="${BTA_NOTES_ROOT:-}"
lock=1
name=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --branch)
      if [ "$#" -lt 2 ]; then
        printf 'Missing value for --branch\n' >&2
        exit 2
      fi
      branch="$2"
      shift 2
      ;;
    --base)
      if [ "$#" -lt 2 ]; then
        printf 'Missing value for --base\n' >&2
        exit 2
      fi
      base_branch="$2"
      shift 2
      ;;
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
    --no-lock)
      lock=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [ -n "$name" ]; then
        printf 'Only one worktree name is supported. Extra argument: %s\n' "$1" >&2
        exit 2
      fi
      name="$1"
      shift
      ;;
  esac
done

if [ -z "$name" ]; then
  usage >&2
  exit 2
fi

case "$name" in
  bta-*) ;;
  *)
    printf 'Worktree name must start with bta-: %s\n' "$name" >&2
    exit 2
    ;;
esac

repo_root="$(git rev-parse --show-toplevel)"
parent_dir="$(dirname "$repo_root")"
worktree_path="$parent_dir/$name"

if [ -z "$branch" ]; then
  branch="bta/${name#bta-}"
  if ! git show-ref --verify --quiet "refs/heads/$branch"; then
    printf 'New ephemeral worktrees require --branch <bugfix|feature|chore>/trello-<id>/<slug>; refusing to create legacy branch %s\n' "$branch" >&2
    exit 2
  fi
else
  if [[ "$branch" =~ ^(bugfix|feature|chore)/trello-([0-9]+)/([a-z0-9]+(-[a-z0-9]+)*)$ ]]; then
    :
  elif [[ "$branch" =~ ^(bugfix|feature|chore)/trello-([0-9]+)-([a-z0-9]+(-[a-z0-9]+)*)$ ]]; then
    # Existing ephemeral branches used the pre-hierarchy naming convention.
    :
  else
    printf 'Ephemeral branch must match <bugfix|feature|chore>/trello-<id>/<lowercase-slug>: %s\n' "$branch" >&2
    exit 2
  fi
fi

if [ -z "$canonical" ]; then
  canonical="$repo_root"
fi

if [ -e "$worktree_path" ]; then
  printf 'Refusing to overwrite existing path: %s\n' "$worktree_path" >&2
  exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/$branch"; then
  if ! git show-ref --verify --quiet "refs/heads/$base_branch"; then
    printf 'Base branch does not exist locally: %s\n' "$base_branch" >&2
    exit 1
  fi

  git branch "$branch" "$base_branch"
  printf 'Created branch %s from %s\n' "$branch" "$base_branch"
else
  printf 'Using existing branch %s\n' "$branch"
fi

if [ "$lock" -eq 1 ]; then
  git worktree add --lock "$worktree_path" "$branch"
else
  git worktree add "$worktree_path" "$branch"
fi

setup_args=(--canonical "$canonical")
if [ -n "$notes_root" ]; then
  setup_args+=(--notes-root "$notes_root")
fi

"$setup_script" "${setup_args[@]}" "$worktree_path"

git -C "$worktree_path" status --short --branch
