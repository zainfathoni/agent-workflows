# Issue Tracker: GitHub

Issues and PRDs for this repo live as GitHub issues in `{{REPO}}`. Use the `gh` CLI for all operations.

## Conventions

- Create an issue: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- Read an issue: `gh issue view <number> --comments`.
- List issues: `gh issue list --state open --json number,title,body,labels,comments` with appropriate `--label` and `--state` filters.
- Comment on an issue: `gh issue comment <number> --body "..."`.
- Apply or remove labels: `gh issue edit <number> --add-label "..."` or `--remove-label "..."`.
- Close issues through PR merge when possible by using `Closes #<number>` in the PR body.

## Source Of Truth

GitHub Issues are the source of truth for work. Do not create repo-local ticket mirrors or use local backlog files as an authoritative queue.

## Skill Publishing

When a skill says "publish to the issue tracker", create or update a GitHub issue.

When a skill says "fetch the relevant ticket", run `gh issue view <number> --comments`.
