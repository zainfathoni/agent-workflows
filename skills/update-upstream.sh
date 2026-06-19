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
  to-issues
  to-prd
  triage
)

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
