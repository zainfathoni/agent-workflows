# Issue Tracker: GitHub

Issues and PRDs for this repo live as GitHub issues in `{{REPO}}`. Use the `gh` CLI for all operations.

## Conventions

- Create an issue: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- Read an issue: `gh issue view <number> --comments`.
- List issues: `gh issue list --state open --json number,title,body,labels,comments` with appropriate `--label` and `--state` filters.
- Comment on an issue: `gh issue comment <number> --body "..."`.
- Apply or remove labels: `gh issue edit <number> --add-label "..."` or `--remove-label "..."`.
- Close issues through PR merge when possible by using `Closes #<number>` in the PR body.
- When an issue body includes `Blocked by: #<number>`, also create the real GitHub issue dependency relationship. Markdown alone is not enough.

## Source Of Truth

GitHub Issues are the source of truth for work. Do not create repo-local ticket mirrors or use local backlog files as an authoritative queue.

GitHub's issue dependency graph is the canonical source for issue-to-issue blockers. A markdown `Blocked by:` line is useful documentation, but it must be kept in sync with a real GitHub `blockedBy` relationship. Use the shared helper to audit or repair blocker relationships:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/ralph/github-blockers.sh audit --repo {{REPO}} --state all
~/Code/GitHub/zainfathoni/agent-workflows/ralph/github-blockers.sh sync --repo {{REPO}} --state all
```

## Skill Publishing

When a skill says "publish to the issue tracker", create or update a GitHub issue.

When a skill says "fetch the relevant ticket", run `gh issue view <number> --comments`.
