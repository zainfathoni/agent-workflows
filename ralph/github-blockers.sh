#!/usr/bin/env bash
# Audit/sync GitHub issue dependency edges from markdown "Blocked by:" lines.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  github-blockers.sh audit --repo OWNER/REPO [--state all|open]
  github-blockers.sh sync --repo OWNER/REPO [--state all|open]
  github-blockers.sh check-issue --repo OWNER/REPO --issue NUMBER

Commands:
  audit       Print markdown Blocked by references and missing real dependency edges.
  sync        Add missing GitHub Blocked by relationships found in issue bodies.
  check-issue Fail when the issue has any open real blockedBy dependencies.

Notes:
  - Markdown "Blocked by:" lines are documentation only.
  - GitHub's issue dependency graph is the canonical blocker source.
  - Requires gh authentication with repository access.
USAGE
}

if [ "$#" -lt 1 ]; then
  usage >&2
  exit 2
fi

COMMAND=$1
shift
if [ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ]; then
  usage
  exit 0
fi
REPO=${RALPH_REPO:-}
STATE=all
ISSUE=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      REPO=$2
      shift 2
      ;;
    --state)
      STATE=$2
      shift 2
      ;;
    --issue)
      ISSUE=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -z "$REPO" ]; then
  printf 'Missing --repo OWNER/REPO or RALPH_REPO.\n' >&2
  exit 2
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$1" >&2
    exit 2
  fi
}

require_command gh
require_command python3

case "$COMMAND" in
  audit|sync)
    TMP_ISSUES=$(mktemp)
    trap 'rm -f "$TMP_ISSUES"' EXIT
    gh issue list --repo "$REPO" --state "$STATE" --limit 1000 --json number,title,state,body > "$TMP_ISSUES"
    python3 - "$COMMAND" "$REPO" "$TMP_ISSUES" <<'PY'
import json
import re
import subprocess
import sys

command = sys.argv[1]
repo = sys.argv[2]
issues_path = sys.argv[3]
owner, name = repo.split('/', 1)
issues = json.load(open(issues_path))

blocked_line = re.compile(r'blocked\s+by\s*:\s*(.+)', re.I)
ref = re.compile(r'(?:#|issues/)(\d+)')

candidates = []
needed_numbers = set()
for issue in issues:
    refs = []
    for line in (issue.get('body') or '').splitlines():
        match = blocked_line.search(line)
        if not match:
            continue
        refs.extend(int(value) for value in ref.findall(match.group(1)))
    refs = sorted({value for value in refs if value != issue['number']})
    if refs:
        candidates.append((issue, refs))
        needed_numbers.add(issue['number'])
        needed_numbers.update(refs)

if not candidates:
    print('No markdown Blocked by references found.')
    raise SystemExit(0)

fields = []
for number in sorted(needed_numbers):
    fields.append(
        f'i{number}: issue(number:{number}) '
        '{ id number title state blockedBy(first:50) { nodes { id number title state url } totalCount } }'
    )
query = 'query($owner:String!, $repo:String!) { repository(owner:$owner, name:$repo) { ' + ' '.join(fields) + ' } }'
result = subprocess.run(
    ['gh', 'api', 'graphql', '-f', f'query={query}', '-f', f'owner={owner}', '-f', f'repo={name}'],
    text=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    check=True,
)
repository = json.loads(result.stdout)['data']['repository']

missing = []
print('Markdown Blocked by audit:')
for issue, expected in candidates:
    current = {node['number'] for node in repository[f"i{issue['number']}"]['blockedBy']['nodes']}
    issue_missing = [number for number in expected if number not in current]
    for number in issue_missing:
        missing.append((issue['number'], number))
    print(f"- #{issue['number']} {issue['state']}: expected {expected}; real {sorted(current)}; missing {issue_missing} — {issue['title']}")

if command == 'audit':
    if missing:
        print(f'Missing relationships: {len(missing)}')
        raise SystemExit(1)
    print('All markdown blockers have matching GitHub dependency edges.')
    raise SystemExit(0)

for issue_number, blocker_number in missing:
    issue_id = repository[f'i{issue_number}']['id']
    blocker_id = repository[f'i{blocker_number}']['id']
    mutation = '''mutation($issueId:ID!, $blockingIssueId:ID!) {
      addBlockedBy(input:{issueId:$issueId, blockingIssueId:$blockingIssueId}) { issue { number } }
    }'''
    subprocess.run(
        ['gh', 'api', 'graphql', '-f', f'query={mutation}', '-f', f'issueId={issue_id}', '-f', f'blockingIssueId={blocker_id}'],
        check=True,
        stdout=subprocess.DEVNULL,
    )
    print(f'Added: #{issue_number} blocked by #{blocker_number}')

if not missing:
    print('No missing relationships to add.')
PY
    ;;
  check-issue)
    if [ -z "$ISSUE" ]; then
      printf 'Missing --issue NUMBER.\n' >&2
      exit 2
    fi
    OWNER=${REPO%%/*}
    NAME=${REPO#*/}
    TMP_CHECK=$(mktemp)
    trap 'rm -f "$TMP_CHECK"' EXIT
    gh api graphql \
      -f query='query($owner:String!, $repo:String!, $number:Int!) { repository(owner:$owner, name:$repo) { issue(number:$number) { number title blockedBy(first:50) { nodes { number title state url } totalCount } } } }' \
      -f owner="$OWNER" \
      -f repo="$NAME" \
      -F number="$ISSUE" > "$TMP_CHECK"
    python3 - "$TMP_CHECK" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1]))['data']['repository']['issue']
open_blockers = [node for node in data['blockedBy']['nodes'] if node['state'] == 'OPEN']
if open_blockers:
    print(f"Issue #{data['number']} is blocked by open issue(s):")
    for blocker in open_blockers:
        print(f"- #{blocker['number']} {blocker['title']} — {blocker['url']}")
    raise SystemExit(1)
print(f"Issue #{data['number']} has no open GitHub blockedBy dependencies.")
PY
    ;;
  *)
    printf 'Unknown command: %s\n' "$COMMAND" >&2
    usage >&2
    exit 2
    ;;
esac
