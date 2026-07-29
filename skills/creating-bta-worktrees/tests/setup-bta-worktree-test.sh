#!/usr/bin/env bash

set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
setup_script="$skill_dir/scripts/setup-bta-worktree.sh"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

canonical="$test_root/bookthatapp"
notes_root="$test_root/notes"
worktree="$test_root/bta-test"

mkdir -p "$canonical" "$notes_root/.agents" "$notes_root/.amp" "$notes_root/.claude" "$worktree"
git -C "$canonical" init --quiet

ln -s "$test_root/old-agents" "$worktree/.agents"
ln -s "$test_root/old-claude" "$worktree/.claude"
mkdir "$worktree/docs"
printf 'preserve me\n' > "$worktree/docs/existing.txt"

"$setup_script" --canonical "$canonical" --notes-root "$notes_root" "$worktree"

test "$(readlink "$worktree/.agents")" = "$notes_root/.agents"
test "$(readlink "$worktree/.amp")" = "$notes_root/.amp"
test "$(readlink "$worktree/.claude")" = "$notes_root/.claude"
test ! -L "$worktree/docs"
test "$(cat "$worktree/docs/existing.txt")" = "preserve me"

printf 'setup-bta-worktree symlink test passed\n'
