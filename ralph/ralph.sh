#!/bin/bash
# Ralph - execution-only GitHub Agent Queue runner.
#
# Usage:
#   ./ralph.sh                         # Run up to 10 one-issue sessions
#   ./ralph.sh 1                       # Run exactly one one-issue session
#   RALPH_RUNNER=claude ./ralph.sh 1   # Force Claude Code
#   RALPH_RUNNER=opencode ./ralph.sh 1 # Force opencode
#   RALPH_ISSUE=168 ./ralph.sh 1       # Force one validated issue
#
# Environment:
#   RALPH_WORKSPACE                    default: directory containing invoked ralph.sh
#   RALPH_REPO                         default: inferred from gh in workspace
#   RALPH_PROJECT_OWNER                optional GitHub Project owner
#   RALPH_PROJECT_NUMBER               optional GitHub Project number
#   RALPH_RUNNER                       opencode or claude; default: opencode, then claude
#   RALPH_MODEL                        optional runner model override
#   RALPH_ISSUE                        optional issue number, still validated by PROMPT.md
#   RALPH_NOTE                         optional runtime note appended to the prompt
#   RALPH_BRANCH_PREFIX                default: agent/issue-
#   RALPH_AUTO_APPROVE                 default: 1; set 0 to avoid permission auto-approval
#   RALPH_SLEEP_SECONDS                default: 2
#   RALPH_ITERATION_TIMEOUT_SECONDS    default: 1200; set 0 to disable

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAX_ITERATIONS=${1:-10}
SLEEP_SECONDS=${RALPH_SLEEP_SECONDS:-2}
ITERATION_TIMEOUT_SECONDS=${RALPH_ITERATION_TIMEOUT_SECONDS:-1200}
RUNNER=${RALPH_RUNNER:-}
MODEL=${RALPH_MODEL:-}
NOTE=${RALPH_NOTE:-}
ISSUE=${RALPH_ISSUE:-}
WORKSPACE=${RALPH_WORKSPACE:-$SCRIPT_DIR}
REPO=${RALPH_REPO:-}
PROJECT_OWNER=${RALPH_PROJECT_OWNER:-}
PROJECT_NUMBER=${RALPH_PROJECT_NUMBER:-}
BRANCH_PREFIX=${RALPH_BRANCH_PREFIX:-agent/issue-}
AUTO_APPROVE=${RALPH_AUTO_APPROVE:-1}
PROMPT_SOURCE=${RALPH_PROMPT_SOURCE:-$SCRIPT_DIR/PROMPT.md}

usage() {
  printf 'Usage: ./ralph.sh [max_iterations]\n'
  printf '\n'
  printf 'Examples:\n'
  printf '  ./ralph.sh\n'
  printf '  ./ralph.sh 1\n'
  printf '  RALPH_RUNNER=claude ./ralph.sh 1\n'
  printf '  RALPH_ISSUE=168 ./ralph.sh 1\n'
  printf '  RALPH_PROJECT_OWNER=zainfathoni RALPH_PROJECT_NUMBER=6 ./ralph.sh\n'
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ ! -d "$WORKSPACE" ]; then
  printf 'Configured workspace does not exist: %s\n' "$WORKSPACE" >&2
  exit 1
fi

cd "$WORKSPACE"

if ! [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]] || [ "$MAX_ITERATIONS" -lt 1 ]; then
  printf 'max_iterations must be a positive integer: %s\n' "$MAX_ITERATIONS" >&2
  exit 1
fi

if ! [[ "$SLEEP_SECONDS" =~ ^[0-9]+$ ]]; then
  printf 'RALPH_SLEEP_SECONDS must be a non-negative integer: %s\n' "$SLEEP_SECONDS" >&2
  exit 1
fi

if ! [[ "$ITERATION_TIMEOUT_SECONDS" =~ ^[0-9]+$ ]]; then
  printf 'RALPH_ITERATION_TIMEOUT_SECONDS must be a non-negative integer: %s\n' "$ITERATION_TIMEOUT_SECONDS" >&2
  exit 1
fi

if [ -n "$ISSUE" ] && [ "$MAX_ITERATIONS" -gt 1 ]; then
  printf 'RALPH_ISSUE targets exactly one issue; run with max_iterations=1.\n' >&2
  printf 'Example: RALPH_ISSUE=%s ./ralph.sh 1\n' "$ISSUE" >&2
  exit 1
fi

require_command() {
  local command_name=$1

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$command_name" >&2
    exit 1
  fi
}

resolve_runner() {
  if [ -n "$RUNNER" ]; then
    if ! command -v "$RUNNER" >/dev/null 2>&1; then
      printf 'Runner not found: %s\n' "$RUNNER" >&2
      printf 'Install/configure opencode or Claude Code, or set RALPH_RUNNER to a supported command.\n' >&2
      exit 1
    fi
    return
  fi

  if command -v opencode >/dev/null 2>&1; then
    RUNNER=opencode
    return
  fi

  if command -v claude >/dev/null 2>&1; then
    RUNNER=claude
    return
  fi

  printf 'No supported Ralph runner found. Install/configure opencode or Claude Code, or set RALPH_RUNNER.\n' >&2
  exit 1
}

check_runner_auth() {
  local runner_name=${RUNNER##*/}

  case "$runner_name" in
    opencode)
      if ! opencode providers list >/dev/null 2>&1; then
        printf 'opencode is not configured. Run: opencode providers login\n' >&2
        exit 1
      fi
      ;;
    claude)
      if ! claude auth status >/dev/null 2>&1; then
        printf 'Claude Code is not authenticated. Run: claude auth login\n' >&2
        exit 1
      fi
      ;;
    *)
      printf 'Unsupported Ralph runner: %s\n' "$RUNNER" >&2
      printf 'Supported runners: opencode, claude\n' >&2
      exit 1
      ;;
  esac
}

check_gh_auth() {
  if ! gh auth status >/dev/null 2>&1; then
    printf 'GitHub CLI is not authenticated. Run: gh auth login\n' >&2
    exit 1
  fi
}

resolve_repo_metadata() {
  if [ -z "$REPO" ]; then
    REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
  fi

  if [ -z "$REPO" ]; then
    printf 'Could not determine GitHub repository. Set RALPH_REPO.\n' >&2
    exit 1
  fi

  DEFAULT_BRANCH=$(gh repo view "$REPO" --json defaultBranchRef --jq '.defaultBranchRef.name')

  if [ -z "$DEFAULT_BRANCH" ]; then
    printf 'Could not determine default branch for repo: %s\n' "$REPO" >&2
    exit 1
  fi

  if [ -z "$PROJECT_OWNER" ]; then
    PROJECT_OWNER=${REPO%%/*}
  fi
}

resolve_project_metadata() {
  PROJECT_CONFIGURED=0
  PROJECT_TITLE=none
  PROJECT_ID=none
  STATUS_FIELD_ID=none
  STATUS_TODO_ID=none
  STATUS_IN_PROGRESS_ID=none
  STATUS_DONE_ID=none

  if [ -z "$PROJECT_NUMBER" ]; then
    return
  fi

  PROJECT_CONFIGURED=1

  if ! PROJECT_ID=$(gh project view "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.id'); then
    printf 'Could not read GitHub Project. Check gh auth project scope: gh auth refresh -s project\n' >&2
    exit 1
  fi

  PROJECT_TITLE=$(gh project view "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.title')
  STATUS_FIELD_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.fields[] | select(.name=="Status") | .id')
  STATUS_TODO_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.fields[] | select(.name=="Status") | .options[] | select(.name=="Todo") | .id')
  STATUS_IN_PROGRESS_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.fields[] | select(.name=="Status") | .options[] | select(.name=="In Progress") | .id')
  STATUS_DONE_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.fields[] | select(.name=="Status") | .options[] | select(.name=="Done") | .id')

  if [ -z "$PROJECT_ID" ] || [ -z "$STATUS_FIELD_ID" ] || [ -z "$STATUS_TODO_ID" ] || [ -z "$STATUS_IN_PROGRESS_ID" ] || [ -z "$STATUS_DONE_ID" ]; then
    printf 'Project %s/%s must have Status options Todo, In Progress, and Done.\n' "$PROJECT_OWNER" "$PROJECT_NUMBER" >&2
    exit 1
  fi
}

run_with_timeout() {
  local output_file=$1
  shift

  python3 - "$ITERATION_TIMEOUT_SECONDS" "$output_file" "$@" <<'PY'
import os
import select
import signal
import subprocess
import sys
import time

timeout = int(sys.argv[1])
output_path = sys.argv[2]
command = sys.argv[3:]

use_process_group = hasattr(os, "setsid")
process = subprocess.Popen(
    command,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    text=True,
    bufsize=1,
    preexec_fn=os.setsid if use_process_group else None,
)

start = time.time()

def terminate_process() -> None:
    try:
        if use_process_group:
            os.killpg(process.pid, signal.SIGTERM)
        else:
            process.terminate()
    except ProcessLookupError:
        return

    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        try:
            if use_process_group:
                os.killpg(process.pid, signal.SIGKILL)
            else:
                process.kill()
        except ProcessLookupError:
            return

with open(output_path, "w", encoding="utf-8", errors="replace") as output:
    stream = process.stdout
    assert stream is not None

    while True:
        if timeout > 0 and time.time() - start >= timeout:
            print(
                f"Ralph iteration timed out after {timeout}s. Terminating runner.",
                file=sys.stderr,
            )
            terminate_process()
            sys.exit(124)

        if process.poll() is not None:
            remainder = stream.read()
            if remainder:
                sys.stdout.write(remainder)
                sys.stdout.flush()
                output.write(remainder)
                output.flush()
            sys.exit(process.returncode)

        ready, _, _ = select.select([stream], [], [], 1)
        if not ready:
            continue

        line = stream.readline()
        if not line:
            continue

        sys.stdout.write(line)
        sys.stdout.flush()
        output.write(line)
        output.flush()
PY
}

build_opencode_env_prefix() {
  local env_cmd=(env)
  local var_name

  for var_name in $(env | cut -d= -f1 | grep '^OPENCODE'); do
    env_cmd+=(-u "$var_name")
  done

  OPENCODE_ENV_PREFIX=("${env_cmd[@]}")
}

render_prompt() {
  local prompt_file=$1

  python3 - "$PROMPT_SOURCE" "$prompt_file" "$WORKSPACE" "$REPO" "$PROJECT_CONFIGURED" "$PROJECT_OWNER" "${PROJECT_NUMBER:-none}" "$PROJECT_TITLE" "$PROJECT_ID" "$STATUS_FIELD_ID" "$STATUS_TODO_ID" "$STATUS_IN_PROGRESS_ID" "$STATUS_DONE_ID" "$ISSUE" "$BRANCH_PREFIX" "$DEFAULT_BRANCH" "$NOTE" <<'PY'
from pathlib import Path
import sys

source_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])
workspace = sys.argv[3]
repo = sys.argv[4]
project_configured = sys.argv[5]
project_owner = sys.argv[6]
project_number = sys.argv[7]
project_title = sys.argv[8]
project_id = sys.argv[9]
status_field_id = sys.argv[10]
status_todo_id = sys.argv[11]
status_in_progress_id = sys.argv[12]
status_done_id = sys.argv[13]
issue = sys.argv[14] or "none"
branch_prefix = sys.argv[15]
default_branch = sys.argv[16]
note = sys.argv[17] or "none"

prefix = f"""# Runtime Overrides

Use these runtime values for this Ralph invocation. They override matching defaults in the Agent Queue prompt below.

- Workspace: `{workspace}`
- Repository: `{repo}`
- Default branch: `{default_branch}`
- GitHub Project configured: `{project_configured}`
- GitHub Project owner: `{project_owner}`
- GitHub Project number: `{project_number}`
- GitHub Project title: `{project_title}`
- GitHub Project ID: `{project_id}`
- Project Status field ID: `{status_field_id}`
- Project Status `Todo` option ID: `{status_todo_id}`
- Project Status `In Progress` option ID: `{status_in_progress_id}`
- Project Status `Done` option ID: `{status_done_id}`
- Branch prefix: `{branch_prefix}`
- Forced issue: `{issue}`
- Runtime note: {note}

"""

output_path.write_text(prefix + source_path.read_text(encoding="utf-8"), encoding="utf-8")
PY
}

run_iteration() {
  local iteration=$1
  local output_file=$2
  local runner_name=${RUNNER##*/}
  local message
  local prompt_text
  local cmd

  message="Follow the attached Agent Queue prompt exactly. Execute at most one issue for this iteration. End with exactly one required status marker and then stop cleanly."
  if [ -n "$NOTE" ]; then
    message="$message Runtime note: $NOTE"
  fi

  case "$runner_name" in
    opencode)
      build_opencode_env_prefix

      cmd=("${OPENCODE_ENV_PREFIX[@]}" "$RUNNER" run --dir "$WORKSPACE" --title "Ralph Agent Queue $iteration/$MAX_ITERATIONS" -f "$PROMPT_FILE")
      if [ "$AUTO_APPROVE" != "0" ]; then
        cmd+=(--dangerously-skip-permissions)
      fi
      if [ -n "$MODEL" ]; then
        cmd+=(--model "$MODEL")
      fi
      cmd+=(-- "$message")
      ;;
    claude)
      prompt_text=$(<"$PROMPT_FILE")
      cmd=("$RUNNER" -p)
      if [ "$AUTO_APPROVE" != "0" ]; then
        cmd+=(--dangerously-skip-permissions)
      fi
      if [ -n "$MODEL" ]; then
        cmd+=(--model "$MODEL")
      fi
      cmd+=("$prompt_text")
      ;;
    *)
      printf 'Unsupported Ralph runner: %s\n' "$RUNNER" >&2
      exit 1
      ;;
  esac

  run_with_timeout "$output_file" "${cmd[@]}"
}

require_command gh
require_command python3
resolve_runner
check_runner_auth
check_gh_auth
resolve_repo_metadata
resolve_project_metadata

if [ ! -f "$PROMPT_SOURCE" ]; then
  printf 'Prompt file not found: %s\n' "$PROMPT_SOURCE" >&2
  exit 1
fi

PROMPT_FILE=$(mktemp)
trap 'rm -f "$PROMPT_FILE"' EXIT
render_prompt "$PROMPT_FILE"

printf 'Starting Ralph Agent Queue with %s\n' "$RUNNER"
printf 'Workspace: %s\n' "$WORKSPACE"
printf 'Repository: %s\n' "$REPO"
if [ "$PROJECT_CONFIGURED" -eq 1 ]; then
  printf 'Project: %s/%s (%s)\n' "$PROJECT_OWNER" "$PROJECT_NUMBER" "$PROJECT_TITLE"
else
  printf 'Project: not configured; using labels-only fallback\n'
fi
printf 'Max iterations: %s\n' "$MAX_ITERATIONS"
if [ "$ITERATION_TIMEOUT_SECONDS" -gt 0 ]; then
  printf 'Iteration timeout: %ss\n' "$ITERATION_TIMEOUT_SECONDS"
else
  printf 'Iteration timeout: disabled\n'
fi
if [ "$AUTO_APPROVE" != "0" ]; then
  printf 'Permission auto-approval: enabled\n'
else
  printf 'Permission auto-approval: disabled\n'
fi
if [ -n "$ISSUE" ]; then
  printf 'Forced issue: #%s\n' "$ISSUE"
fi

READY_FOR_REVIEW_COUNT=0
DEMOTED_COUNT=0

for i in $(seq 1 "$MAX_ITERATIONS"); do
  printf '\n=======================================================\n'
  printf ' Ralph Agent Queue Iteration %s of %s\n' "$i" "$MAX_ITERATIONS"
  printf '=======================================================\n'

  OUTPUT_FILE=$(mktemp)
  set +e
  run_iteration "$i" "$OUTPUT_FILE"
  RUN_EXIT=$?
  set -e

  OUTPUT=$(<"$OUTPUT_FILE")
  rm -f "$OUTPUT_FILE"

  if [ "$RUN_EXIT" -ne 0 ]; then
    printf '\nRalph runner failed with exit code %s.\n' "$RUN_EXIT" >&2
    case "${RUNNER##*/}" in
      opencode)
        printf 'If this was an authentication issue, run: opencode providers login\n' >&2
        ;;
      claude)
        printf 'If this was an authentication issue, run: claude auth login\n' >&2
        ;;
    esac
    exit "$RUN_EXIT"
  fi

  STATUS_MARKERS=$(printf '%s\n' "$OUTPUT" | tr -d '\r' | grep -Ex '<status>(COMPLETE|READY_FOR_REVIEW|BLOCKED|DEMOTED)</status>' || true)
  STATUS_MARKER_COUNT=$(printf '%s\n' "$STATUS_MARKERS" | sed '/^$/d' | wc -l | tr -d ' ')
  STATUS_MARKER=$(printf '%s\n' "$STATUS_MARKERS" | sed -n '1p')
  LAST_NONEMPTY_LINE=$(printf '%s\n' "$OUTPUT" | tr -d '\r' | sed '/^[[:space:]]*$/d' | tail -n 1)

  if [ "$STATUS_MARKER_COUNT" -ne 1 ]; then
    printf '\nRalph stopped because the agent must print exactly one recognized status marker.\n' >&2
    printf 'Found %s status markers. Expected one of: <status>COMPLETE</status>, <status>READY_FOR_REVIEW</status>, <status>DEMOTED</status>, <status>BLOCKED</status>\n' "$STATUS_MARKER_COUNT" >&2
    exit 1
  fi

  if [ "$LAST_NONEMPTY_LINE" != "$STATUS_MARKER" ]; then
    printf '\nRalph stopped because the status marker was not the final non-empty output line.\n' >&2
    printf 'Final non-empty line must be one of: <status>COMPLETE</status>, <status>READY_FOR_REVIEW</status>, <status>DEMOTED</status>, <status>BLOCKED</status>\n' >&2
    exit 1
  fi

  case "$STATUS_MARKER" in
    '<status>COMPLETE</status>')
      printf '\nRalph completed the Agent Queue.\n'
      printf 'Completed at iteration %s of %s.\n' "$i" "$MAX_ITERATIONS"
      exit 0
      ;;
    '<status>BLOCKED</status>')
      printf '\nRalph stopped because the agent reported BLOCKED.\n' >&2
      exit 1
      ;;
    '<status>DEMOTED</status>')
      DEMOTED_COUNT=$((DEMOTED_COUNT + 1))
      printf 'Iteration %s demoted a non-ready issue. Continuing if iterations remain.\n' "$i"
      sleep "$SLEEP_SECONDS"
      continue
      ;;
    '<status>READY_FOR_REVIEW</status>')
      READY_FOR_REVIEW_COUNT=$((READY_FOR_REVIEW_COUNT + 1))
      printf 'Iteration %s handed off a PR. Continuing if iterations remain.\n' "$i"
      sleep "$SLEEP_SECONDS"
      continue
      ;;
  esac
done

if [ "$READY_FOR_REVIEW_COUNT" -gt 0 ] || [ "$DEMOTED_COUNT" -gt 0 ]; then
  printf '\nRalph reached max iterations after %s PR handoff(s) and %s demotion(s).\n' "$READY_FOR_REVIEW_COUNT" "$DEMOTED_COUNT"
  printf 'The Agent Queue may still contain more ready work.\n'
  exit 0
fi

printf '\nRalph reached max iterations without completing the queue, handing off a PR, or demoting an issue.\n' >&2
exit 1
