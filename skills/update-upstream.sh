#!/usr/bin/env bash
# Install or update upstream-tracked skills without touching local-owned skills.

set -euo pipefail

UPSTREAM_PACKAGE=${UPSTREAM_SKILLS_PACKAGE:-mattpocock/skills}
IMPROVE_PACKAGE=${IMPROVE_SKILLS_PACKAGE:-shadcn/improve}
UPSTREAM_AGENTS=${UPSTREAM_SKILLS_AGENTS:-amp claude-code codex}

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

IMPROVE_SKILLS=(
  improve
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
CANONICAL_UPSTREAM_ROOT=$HOME/.agents/skills
GLOBAL_SKILL_LOCK=${XDG_STATE_HOME:+$XDG_STATE_HOME/skills/.skill-lock.json}
GLOBAL_SKILL_LOCK=${GLOBAL_SKILL_LOCK:-$HOME/.agents/.skill-lock.json}

normalized_agents=$(printf '%s' "$UPSTREAM_AGENTS" | tr '[:space:]' ' ')
read -r -a upstream_agents <<< "$normalized_agents"
if [ "${#upstream_agents[@]}" -eq 0 ]; then
  printf 'UPSTREAM_SKILLS_AGENTS must name at least one supported agent.\n' >&2
  exit 1
fi

agent_args=(--agent "${upstream_agents[@]}")

agent_skill_root() {
  case "$1" in
    amp)
      printf '%s/agents/skills\n' "${XDG_CONFIG_HOME:-$HOME/.config}"
      ;;
    claude-code)
      printf '%s/skills\n' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
      ;;
    codex)
      printf '%s/skills\n' "${CODEX_HOME:-$HOME/.codex}"
      ;;
    *)
      printf 'Unsupported agent in UPSTREAM_SKILLS_AGENTS: %s (supported: amp claude-code codex)\n' "$1" >&2
      return 1
      ;;
  esac
}

verify_skill_file() {
  local path="$1"

  if [ ! -f "$path" ]; then
    printf 'Missing installed skill file: %s\n' "$path" >&2
    return 1
  fi
}

verify_improve_installation() {
  local agent
  local root

  for agent in "${upstream_agents[@]}"; do
    root=$(agent_skill_root "$agent")
    verify_skill_file "$root/improve/SKILL.md"
    verify_skill_file "$root/improve/references/audit-playbook.md"
    verify_skill_file "$root/improve/references/closing-the-loop.md"
    verify_skill_file "$root/improve/references/plan-template.md"
  done

  # Multi-target installs normally use this canonical copy. A single-target
  # install may copy directly to the agent destination instead.
  if [ -e "$CANONICAL_UPSTREAM_ROOT/improve" ] || [ -L "$CANONICAL_UPSTREAM_ROOT/improve" ]; then
    verify_skill_file "$CANONICAL_UPSTREAM_ROOT/improve/SKILL.md"
    verify_skill_file "$CANONICAL_UPSTREAM_ROOT/improve/references/audit-playbook.md"
    verify_skill_file "$CANONICAL_UPSTREAM_ROOT/improve/references/closing-the-loop.md"
    verify_skill_file "$CANONICAL_UPSTREAM_ROOT/improve/references/plan-template.md"
  fi

  node -e '
    const fs = require("fs");
    const lockPath = process.argv[1];
    const lock = JSON.parse(fs.readFileSync(lockPath, "utf8"));
    const improve = lock.skills && lock.skills.improve;
    if (!improve || improve.source !== "shadcn/improve" || improve.sourceType !== "github") {
      console.error(`Unexpected improve provenance in ${lockPath}`);
      process.exit(1);
    }
  ' "$GLOBAL_SKILL_LOCK"
}

for agent in "${upstream_agents[@]}"; do
  agent_skill_root "$agent" >/dev/null
done

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
  "${agent_args[@]}" \
  --copy \
  --full-depth \
  --yes \
  "${skill_args[@]}"

improve_skill_args=()
for skill in "${IMPROVE_SKILLS[@]}"; do
  improve_skill_args+=(--skill "$skill")
done

npx --yes skills@latest add "$IMPROVE_PACKAGE" \
  --global \
  "${agent_args[@]}" \
  --copy \
  --yes \
  "${improve_skill_args[@]}"

verify_improve_installation
