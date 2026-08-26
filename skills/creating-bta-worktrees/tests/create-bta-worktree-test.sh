#!/usr/bin/env bash

set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
create_script="$skill_dir/scripts/create-bta-worktree.sh"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

canonical="$test_root/bookthatapp"
notes_root="$test_root/notes"

mkdir -p "$canonical" "$notes_root/.agents" "$notes_root/.claude"
git -C "$canonical" init --quiet
git -C "$canonical" config user.email test@example.com
git -C "$canonical" config user.name Test
printf 'fixture\n' > "$canonical/README.md"
git -C "$canonical" add README.md
git -C "$canonical" commit --quiet -m 'Initial fixture'
git -C "$canonical" branch bta/main
ln -s "$notes_root/.claude" "$canonical/.claude"

if "$create_script" \
  --canonical "$canonical" \
  --notes-root "$notes_root" \
  bta-947-legacy-refusal >"$test_root/refusal.log" 2>&1; then
  printf 'Expected missing --branch to fail\n' >&2
  exit 1
fi
grep -q 'New ephemeral worktrees require --branch' "$test_root/refusal.log"

(
  cd "$canonical"
  "$create_script" \
    --base bta/main \
    --branch bugfix/trello-947/search-save-recovery \
    --canonical "$canonical" \
    --notes-root "$notes_root" \
    bta-947-search-save-recovery
)

test "$(git -C "$test_root/bta-947-search-save-recovery" branch --show-current)" = \
  'bugfix/trello-947/search-save-recovery'
test ! -e "$test_root/bta-947-search-save-recovery/.amp"
test ! -L "$test_root/bta-947-search-save-recovery/.amp"

(
  cd "$canonical"
  "$create_script" \
    --base bta/main \
    --branch bugfix/trello-947/retry-feedback \
    --canonical "$canonical" \
    --notes-root "$notes_root" \
    bta-947-retry-feedback
)

test "$(git -C "$test_root/bta-947-retry-feedback" branch --show-current)" = \
  'bugfix/trello-947/retry-feedback'

printf 'create-bta-worktree branch naming test passed\n'
