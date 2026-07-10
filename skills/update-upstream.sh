#!/usr/bin/env bash
# Install or update upstream-tracked Matt Pocock skills without touching local-owned skills.

set -euo pipefail

UPSTREAM_PACKAGE=${UPSTREAM_SKILLS_PACKAGE:-mattpocock/skills}
UPSTREAM_AGENTS=${UPSTREAM_SKILLS_AGENTS:-*}

# Keep this list aligned with skills/README.md. Do not include local-owned skills
# such as teach; they are installed from this repository via skills/install.sh.
UPSTREAM_SKILLS=(
  ask-matt
  grilling
  domain-modeling
  grill-with-docs
  codebase-design
  diagnosing-bugs
  writing-great-skills
  resolving-merge-conflicts
  handoff
  prototype
  improve-codebase-architecture
  setup-matt-pocock-skills
  tdd
  to-spec
  to-tickets
  implement
  wayfinder
  research
  code-review
  triage
)

# Upstream skills that were renamed or merged in v1.1 and no longer exist.
# Older deprecated skills that should never be installed are also included.
# The skills installer does not remove old skills, so use `skills remove` for
# agent-specific cleanup, then fall back to filesystem removal for any stragglers.
DEPRECATED_UPSTREAM_SKILLS=(
  to-prd
  to-issues
  to-plan
  caveman
  zoom-out
)

LOCAL_ROOT=${AGENT_SKILLS_DIR:-$HOME/.agents/skills}

remove_deprecated() {
  local skill="$1"
  local target

  # Use the Skills CLI to remove from all registered agent directories.
  npx --yes skills@latest remove "$skill" --global --yes 2>/dev/null || true

  # Filesystem fallback for any agent directories the CLI missed.
  for target in "$LOCAL_ROOT/$skill" "$HOME/.claude/skills/$skill"; do
    if [ -e "$target" ] || [ -L "$target" ]; then
      rm -r "$target"
      printf 'Removed deprecated skill: %s\n' "$target"
    fi
  done
}

for skill in "${DEPRECATED_UPSTREAM_SKILLS[@]}"; do
  remove_deprecated "$skill"
done

skill_args=()
for skill in "${UPSTREAM_SKILLS[@]}"; do
  skill_args+=(--skill "$skill")
done

npx --yes skills@latest add "$UPSTREAM_PACKAGE" \
  --global \
  --agent "$UPSTREAM_AGENTS" \
  --full-depth \
  --yes \
  "${skill_args[@]}"
