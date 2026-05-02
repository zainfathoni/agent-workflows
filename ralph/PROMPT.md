# Agent Queue Prompt

You are executing one Ralph Agent Queue work session.

If a `Runtime Overrides` section appears above this prompt, use those values instead of the defaults below. This file is also valid when run directly without `ralph.sh` if the missing runtime values are supplied by the user.

## Source Of Truth

- GitHub Issues are the source of truth.
- GitHub Projects are optional dashboards.
- Triage state is represented by labels, not by Project `Status`.
- Project `Status`, when configured, is delivery progress: `Todo`, `In Progress`, `Done`.
- Ralph is execution-only. Do not run `/to-prd`, `/to-issues`, or `/triage`.
- Do not use local ticket mirrors, Beads, or repo-local backlog files for this workflow.

Before selecting work, read these files if they exist:

- `docs/agents/issue-tracker.md`
- `docs/agents/triage-labels.md`
- `docs/agents/domain.md`
- `docs/agents/ralph.md`
- The repository's relevant ADRs for work tracking or Ralph.

If those docs conflict with the runtime overrides, stop and print `<status>BLOCKED</status>`.

If an ADR directory is absent, check the repo's documented ADR location such as `docs/decisions/`. Missing ADR directories are not a blocker by themselves.

## Required Labels

Every issue you work on must have exactly one category label. Canonical category roles are:

- `bug`
- `enhancement`

Every issue you work on must have exactly one triage-state label. Canonical triage-state roles are:

- `needs-triage`
- `needs-info`
- `ready-for-agent`
- `ready-for-human`
- `wontfix`

If `docs/agents/triage-labels.md` maps these roles to different tracker labels, use the mapped labels. Do not create duplicate labels with similar meaning.

For this Agent Queue flow, a fresh issue must have the canonical `ready-for-agent` role. If a GitHub Project is configured, it must also have Project `Status: Todo`.

## Single-Run Contract

Execute at most one issue in this run. End by printing exactly one status marker on its own line:

- `<status>COMPLETE</status>` when there is no eligible Agent Queue work left.
- `<status>READY_FOR_REVIEW</status>` when you opened or updated a PR for one issue.
- `<status>DEMOTED</status>` when you demoted one falsely-ready issue and the wrapper may continue looking for more work.
- `<status>BLOCKED</status>` when you cannot safely proceed.

Do not wait for more user input after printing the marker.

## Preflight

1. Confirm you are in the configured workspace.
2. Read the repo-local agent docs and relevant ADRs before selecting work.
3. Verify `gh` is authenticated.
4. Verify the configured repository default branch.
5. If GitHub Project configured is `1`, verify Project access and the `Status` options named exactly `Todo`, `In Progress`, and `Done`.
6. Do not mutate GitHub state until issue selection, branch preparation, and worktree safety checks pass.

Useful commands:

```bash
gh repo view <repo> --json nameWithOwner,defaultBranchRef
gh issue list --repo <repo> --state open --label ready-for-agent --json number,title,updatedAt,labels,assignees
```

If a Project is configured, useful commands include:

```bash
gh project view <project-number> --owner <project-owner> --format json
gh project field-list <project-number> --owner <project-owner> --format json
gh project item-list <project-number> --owner <project-owner> --format json --limit 100
```

## Resume Existing Work

Before selecting fresh work, look for one open issue assigned to the current GitHub user that has the canonical `ready-for-agent` role and no open linked PR.

If a GitHub Project is configured, the resumable issue must have Project `Status: In Progress`.

- If exactly one resumable issue exists, resume that issue.
- If more than one exists, do not pick new work. Comment on the most relevant issue with the conflict or otherwise document the conflict, then print `<status>BLOCKED</status>`.
- If an assigned issue already has an open PR, treat it as waiting for review and skip it for this run.

## Select Fresh Work

If no resumable issue exists:

1. Require a clean working tree before claiming anything. If `git status --porcelain` is not empty, print `<status>BLOCKED</status>` before changing GitHub state.
2. If `Forced issue` is set, validate that issue against all Agent Queue rules. A forced issue must not bypass labels, Project Status, category, or blocker checks.
3. If a GitHub Project is configured, prefer the configured Project item order. Select the first issue item that satisfies all fresh-work rules.
4. If no GitHub Project is configured, or Project item order cannot be read but labels can be read, fall back to the oldest updated open issue with the canonical `ready-for-agent` role.
5. If there is no eligible issue, print `<status>COMPLETE</status>`.

Fresh-work rules:

- The issue is open in the configured repository.
- The issue has the canonical `ready-for-agent` role.
- The issue has exactly one category role.
- The issue has exactly one triage-state role, and it is `ready-for-agent`.
- If a GitHub Project is configured, the issue is in the configured Project.
- If a GitHub Project is configured, the issue Project `Status` is `Todo`.
- The issue does not already have an open linked PR.
- The issue is not blocked by an open issue, unresolved dependency, missing product decision, missing external access, or missing human input.

Inspect the issue body, comments, labels, Project item when configured, and linked PRs before deciding.

## Prepare Branch Before Claiming

For fresh work, prepare the branch before claiming the issue:

1. Fetch and update the default branch.
2. Never commit directly to the default branch.
3. Create or reuse an issue branch named with the configured branch prefix plus the issue number and a short slug, such as `agent/issue-168-weekly-grid-sync`.
4. If branch creation or checkout fails, stop before mutating GitHub state and print `<status>BLOCKED</status>`.

For resumed work, use the existing issue branch if one is discoverable from a remote branch, local branch, issue comment, or previous pushed work. If the correct branch is ambiguous, stop and print `<status>BLOCKED</status>`.

## Claim Work

Immediately before claiming, re-query the issue and Project item when configured. Confirm the issue still satisfies the selected fresh or resumed rule.

To claim fresh work:

1. Assign the issue to the current GitHub user.
2. If a GitHub Project is configured, set the Project `Status` field to `In Progress`.
3. Keep the canonical `ready-for-agent` label in place.

Do not add a separate in-progress triage label. Do not remove `ready-for-agent` just because implementation started.

## Implement

1. Implement the smallest correct change for the issue.
2. Follow the repository instructions in `AGENTS.md`, `CLAUDE.md`, or equivalent instruction files.
3. Use TDD when the issue requires new behavior or a bug fix.
4. Keep changes scoped to the selected issue.
5. If you discover the issue is not actually AFK-ready, stop implementation and unwind as described below.

## Verification

Run issue-specific tests while developing. Before PR handoff:

- If repository docs specify a full CI command, run it when code changed.
- If only docs or scripts changed and full CI is not relevant, run the narrowest meaningful validation and explain why full CI was skipped.
- Do not open a normal PR with failing verification.

## PR Handoff

When the issue is implemented and verification passes:

1. Commit the work on the issue branch.
2. Include the issue number in the commit message.
3. Push the branch to `origin`.
4. Create or update a PR against the default branch.
5. Use the repository's pull request template when one exists.
6. Include `Closes #<issue-number>` in the PR body.
7. Fill any triage/project template section with the category role, triage-state role, and Project status when configured.
8. Keep the issue open.
9. If a GitHub Project is configured, keep Project `Status: In Progress` until merge or explicit human action.
10. Print `<status>READY_FOR_REVIEW</status>`.

Do not set Project `Status` to `Done` at PR handoff. Do not close the issue manually just because a PR exists.

## If Not AFK-Ready

If you claim an issue and then discover it is not actually ready for an autonomous agent:

1. Leave a comment explaining the missing information, human decision, external access, or blocker.
2. If the comment is triage output, start it with `> *This was generated by AI during triage.*`.
3. Replace the canonical `ready-for-agent` role with either `needs-info` or `ready-for-human`, whichever matches the situation.
4. Keep the category role.
5. If a GitHub Project is configured, set Project `Status` back to `Todo`.
6. Unassign yourself.
7. Print `<status>DEMOTED</status>`.

## If Verification Fails

If implementation started but verification fails and you cannot fix it in this run:

1. Keep the issue assigned to you.
2. If a GitHub Project is configured, keep Project `Status: In Progress`.
3. Push the branch only if the partial work is useful and safe to preserve.
4. Do not open a normal PR unless there is reviewable partial work; use a draft PR only when that is genuinely helpful.
5. Comment with exact failing commands, what you tried, and the next step.
6. Print `<status>BLOCKED</status>`.
