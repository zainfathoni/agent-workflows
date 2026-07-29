#!/usr/bin/env bash

set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
setup_script="$skill_dir/scripts/setup-bta-worktree.sh"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

canonical="$test_root/bookthatapp"
notes_root="$test_root/notes"
amp_project="$test_root/amp-project"
worktree="$test_root/bta-test"
preserved_worktree="$test_root/bta-preserved"

mkdir -p \
  "$canonical" \
  "$notes_root/.agents" \
  "$notes_root/.claude" \
  "$amp_project/.amp" \
  "$worktree" \
  "$preserved_worktree/.amp"
git -C "$canonical" init --quiet

ln -s "$notes_root/.claude" "$canonical/.claude"
ln -s "$amp_project/.amp" "$canonical/.amp"
ln -s "$test_root/old-agents" "$worktree/.agents"
ln -s "$test_root/old-claude" "$worktree/.claude"
printf 'preserve me\n' > "$preserved_worktree/.amp/existing.txt"

"$setup_script" --canonical "$canonical" "$worktree" "$preserved_worktree"

test ! -e "$notes_root/.amp"
test "$(readlink "$worktree/.agents")" = "$notes_root/.agents"
test "$(readlink "$worktree/.amp")" = "$amp_project/.amp"
test "$(readlink "$worktree/.claude")" = "$notes_root/.claude"
test ! -L "$preserved_worktree/.amp"
test "$(cat "$preserved_worktree/.amp/existing.txt")" = "preserve me"

printf 'setup-bta-worktree symlink test passed\n'
