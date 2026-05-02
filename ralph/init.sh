#!/bin/bash
# Onboard a repository for globally installed skills and shared Ralph.

set -euo pipefail

SHARED_RALPH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE=$(pwd)
YES=0
PROJECT_OWNER=${RALPH_PROJECT_OWNER:-}
PROJECT_NUMBER=${RALPH_PROJECT_NUMBER:-}

usage() {
  printf 'Usage: init.sh [--yes] [--workspace PATH] [--project-owner OWNER --project-number NUMBER]\n'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --yes|-y)
      YES=1
      shift
      ;;
    --workspace)
      WORKSPACE=$2
      shift 2
      ;;
    --project-owner)
      PROJECT_OWNER=$2
      shift 2
      ;;
    --project-number)
      PROJECT_NUMBER=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_command() {
  local command_name=$1

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$command_name" >&2
    exit 1
  fi
}

require_command git
require_command gh
require_command python3

if [ ! -d "$WORKSPACE" ]; then
  printf 'Workspace does not exist: %s\n' "$WORKSPACE" >&2
  exit 1
fi

cd "$WORKSPACE"

if [ ! -d .git ]; then
  printf 'Workspace is not a git repository: %s\n' "$WORKSPACE" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  printf 'GitHub CLI is not authenticated. Run: gh auth login\n' >&2
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
DEFAULT_BRANCH=$(gh repo view "$REPO" --json defaultBranchRef --jq '.defaultBranchRef.name')

if [ -z "$PROJECT_OWNER" ]; then
  PROJECT_OWNER=${REPO%%/*}
fi

PROJECT_CONFIGURED=0
PROJECT_TITLE=none
if [ -n "$PROJECT_NUMBER" ]; then
  PROJECT_CONFIGURED=1
  PROJECT_TITLE=$(gh project view "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.title')
fi

AGENT_FILES=()
if [ -f CLAUDE.md ]; then
  AGENT_FILES+=(CLAUDE.md)
fi
if [ -f AGENTS.md ]; then
  AGENT_FILES+=(AGENTS.md)
fi
if [ "${#AGENT_FILES[@]}" -eq 0 ]; then
  AGENT_FILES=(AGENTS.md)
fi
AGENT_FILES_DISPLAY=$(IFS=,; printf '%s' "${AGENT_FILES[*]}")

ENTRYPOINT_MODE=root
if [ -L ralph.sh ] && [ -L PROMPT.md ] && [ "$(readlink ralph.sh)" = "$SHARED_RALPH_DIR/ralph.sh" ] && [ "$(readlink PROMPT.md)" = "$SHARED_RALPH_DIR/PROMPT.md" ]; then
  ENTRYPOINT_MODE=root
elif [ -e ralph.sh ] || [ -e PROMPT.md ] || git ls-files --error-unmatch ralph.sh >/dev/null 2>&1 || git ls-files --error-unmatch PROMPT.md >/dev/null 2>&1; then
  ENTRYPOINT_MODE=.ralph
fi

printf 'Agent Workflows onboarding plan\n'
printf 'Workspace: %s\n' "$WORKSPACE"
printf 'Repository: %s\n' "$REPO"
printf 'Default branch: %s\n' "$DEFAULT_BRANCH"
printf 'Agent instruction file(s): %s\n' "$AGENT_FILES_DISPLAY"
if [ "$PROJECT_CONFIGURED" -eq 1 ]; then
  printf 'GitHub Project: %s/%s (%s)\n' "$PROJECT_OWNER" "$PROJECT_NUMBER" "$PROJECT_TITLE"
else
  printf 'GitHub Project: not configured; labels-only fallback will be documented\n'
fi
printf 'Docs to write/update: docs/agents/issue-tracker.md, docs/agents/triage-labels.md, docs/agents/domain.md, docs/agents/ralph.md\n'
printf 'Labels to ensure: bug, enhancement, needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix\n'
printf 'Local entrypoints: %s\n' "$ENTRYPOINT_MODE"

if [ "$YES" -ne 1 ]; then
  printf '\nApply this setup? [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes|YES)
      ;;
    *)
      printf 'Aborted.\n'
      exit 0
      ;;
  esac
fi

python3 - "$SHARED_RALPH_DIR" "$WORKSPACE" "$REPO" "$DEFAULT_BRANCH" "$PROJECT_CONFIGURED" "$PROJECT_OWNER" "${PROJECT_NUMBER:-none}" "$AGENT_FILES_DISPLAY" <<'PY'
from pathlib import Path
import re
import sys

shared = Path(sys.argv[1])
workspace = Path(sys.argv[2])
repo = sys.argv[3]
default_branch = sys.argv[4]
project_configured = sys.argv[5]
project_owner = sys.argv[6]
project_number = sys.argv[7]
agent_files = [name for name in sys.argv[8].split(",") if name]

values = {
    "REPO": repo,
    "DEFAULT_BRANCH": default_branch,
    "PROJECT_CONFIGURED": project_configured,
    "PROJECT_OWNER": project_owner,
    "PROJECT_NUMBER": project_number,
}

def render(text: str) -> str:
    for key, value in values.items():
        text = text.replace("{{" + key + "}}", value)
    return text

template_root = shared / "templates"
for relative in [
    "docs/agents/issue-tracker.md",
    "docs/agents/triage-labels.md",
    "docs/agents/domain.md",
    "docs/agents/ralph.md",
]:
    destination = workspace / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(render((template_root / relative).read_text(encoding="utf-8")), encoding="utf-8")

block = render((template_root / "agent-skills-block.md").read_text(encoding="utf-8")).strip() + "\n"
pattern = re.compile(r"(?:^|\n)## Agent skills\n.*?(?=\n## |\Z)", re.S)
for agent_file_name in agent_files:
    agent_file = workspace / agent_file_name
    if not agent_file.exists():
        agent_file.write_text("# Agent Instructions\n\n", encoding="utf-8")
    content = agent_file.read_text(encoding="utf-8")
    if pattern.search(content):
        content = pattern.sub("\n" + block.rstrip(), content).rstrip() + "\n"
    else:
        if not content.endswith("\n"):
            content += "\n"
        content = content.rstrip() + "\n\n" + block
    agent_file.write_text(content, encoding="utf-8")
PY

ensure_label() {
  local name=$1
  local color=$2
  local description=$3

  if gh label list --repo "$REPO" --json name --jq '.[].name' | grep -Fx "$name" >/dev/null 2>&1; then
    return
  fi

  gh label create "$name" --repo "$REPO" --color "$color" --description "$description"
}

ensure_label bug d73a4a 'Something is broken'
ensure_label enhancement a2eeef 'New feature or improvement'
ensure_label needs-triage fbca04 'Maintainer needs to evaluate this issue'
ensure_label needs-info d876e3 'Waiting on reporter for more information'
ensure_label ready-for-agent 0e8a16 'Fully specified and ready for an AFK agent'
ensure_label ready-for-human 1d76db 'Requires human implementation or review'
ensure_label wontfix ffffff 'Will not be actioned'

add_exclude() {
  local line=$1
  touch .git/info/exclude
  if ! grep -Fx "$line" .git/info/exclude >/dev/null 2>&1; then
    printf '%s\n' "$line" >> .git/info/exclude
  fi
}

if [ "$ENTRYPOINT_MODE" = root ]; then
  if [ ! -e ralph.sh ]; then
    ln -s "$SHARED_RALPH_DIR/ralph.sh" ralph.sh
  fi
  if [ ! -e PROMPT.md ]; then
    ln -s "$SHARED_RALPH_DIR/PROMPT.md" PROMPT.md
  fi
  add_exclude /ralph.sh
  add_exclude /PROMPT.md
else
  mkdir -p .ralph
  if [ ! -e .ralph/ralph.sh ]; then
    ln -s "$SHARED_RALPH_DIR/ralph.sh" .ralph/ralph.sh
  fi
  if [ ! -e .ralph/PROMPT.md ]; then
    ln -s "$SHARED_RALPH_DIR/PROMPT.md" .ralph/PROMPT.md
  fi
  add_exclude /.ralph/
fi

printf 'Agent Workflows setup complete. Review and commit docs/agents plus %s changes if desired.\n' "$AGENT_FILES_DISPLAY"
