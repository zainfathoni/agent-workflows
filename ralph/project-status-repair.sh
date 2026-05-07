#!/usr/bin/env bash
# Repair safe GitHub Project delivery-status drift before Ralph selects work.

set -euo pipefail

REPO=""
PROJECT_OWNER=""
PROJECT_NUMBER=""
READY_LABEL="ready-for-agent"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: project-status-repair.sh --repo OWNER/REPO --project-owner OWNER --project-number NUMBER [--ready-label LABEL] [--dry-run]

Repairs open ready-for-agent issues in a configured GitHub Project when their
Project Status is a stale/custom queue value such as Ready or Backlog. Safe
repairs only: unassigned issues with no open PR are moved to Status: Todo.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo) REPO=$2; shift 2 ;;
    --project-owner) PROJECT_OWNER=$2; shift 2 ;;
    --project-number) PROJECT_NUMBER=$2; shift 2 ;;
    --ready-label) READY_LABEL=$2; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; usage >&2; exit 1 ;;
  esac
done

if [ -z "$REPO" ] || [ -z "$PROJECT_OWNER" ] || [ -z "$PROJECT_NUMBER" ]; then
  usage >&2
  exit 1
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$1" >&2
    exit 1
  fi
}

require_command gh
require_command jq

PROJECT_ID=$(gh project view "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.id')
FIELD_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.fields[] | select(.name=="Status") | .id')
TODO_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.fields[] | select(.name=="Status") | .options[] | select(.name=="Todo") | .id')

if [ -z "$PROJECT_ID" ] || [ -z "$FIELD_ID" ] || [ -z "$TODO_ID" ]; then
  printf 'Project %s/%s must expose a Status field with a Todo option.\n' "$PROJECT_OWNER" "$PROJECT_NUMBER" >&2
  exit 1
fi

issues_json=$(gh issue list --repo "$REPO" --state open --label "$READY_LABEL" --json number,title,assignees --limit 100)
items_json=$(gh project item-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --limit 200)

repaired=0
skipped=0
missing=0

while IFS= read -r issue; do
  [ -n "$issue" ] || continue
  number=$(jq -r '.number' <<<"$issue")
  title=$(jq -r '.title' <<<"$issue")
  assignee_count=$(jq '.assignees | length' <<<"$issue")

  item=$(jq -c --argjson number "$number" --arg repo "$REPO" '.items[] | select(.content.type=="Issue" and .content.repository==$repo and .content.number==$number)' <<<"$items_json" | head -1)
  if [ -z "$item" ]; then
    printf 'MISSING project item: #%s %s\n' "$number" "$title"
    missing=$((missing + 1))
    continue
  fi

  status=$(jq -r '.status // ""' <<<"$item")
  item_id=$(jq -r '.id' <<<"$item")

  case "$status" in
    Todo)
      printf 'OK Todo: #%s %s\n' "$number" "$title"
      continue
      ;;
    "In Progress"|Done)
      printf 'SKIP %s: #%s %s\n' "$status" "$number" "$title"
      skipped=$((skipped + 1))
      continue
      ;;
  esac

  if [ "$assignee_count" -gt 0 ]; then
    printf 'SKIP assigned (%s): #%s %s\n' "$status" "$number" "$title"
    skipped=$((skipped + 1))
    continue
  fi

  open_pr_count=$(gh pr list --repo "$REPO" --state open --search "$number in:body" --json number --jq 'length')
  if [ "$open_pr_count" -gt 0 ]; then
    printf 'SKIP open PR (%s): #%s %s\n' "$status" "$number" "$title"
    skipped=$((skipped + 1))
    continue
  fi

  printf 'REPAIR %s -> Todo: #%s %s\n' "${status:-unset}" "$number" "$title"
  if [ "$DRY_RUN" -eq 0 ]; then
    gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" --field-id "$FIELD_ID" --single-select-option-id "$TODO_ID" >/dev/null
  fi
  repaired=$((repaired + 1))
done < <(jq -c '.[]' <<<"$issues_json")

printf 'Summary: repaired=%s skipped=%s missing=%s dryRun=%s\n' "$repaired" "$skipped" "$missing" "$DRY_RUN"
