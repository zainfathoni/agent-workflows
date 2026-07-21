# Squash guide template

Read this file only while creating the unique guide in step 3 of [`../SKILL.md`](../SKILL.md).

Use this structure:

````markdown
# Squash Guide for {ticket-id}

Branch: `{branch-name}`
Total commits: X → Suggested: Y squashed commits

## Instructions

Run `git rebase -i {base-branch}`, then replace the content with:

```txt

# Group 1: {Group Description}

pick {hash} {message}
s {hash} {message}
...

```

## Suggested Commit Messages

### Group 1 ({N} commits)

> First commit: "{first commit message}..."

```txt

{Type}: {Short summary}

{Detailed description of what this group of commits accomplishes}

Changes:

- {Bullet point of specific change}
- {Bullet point of specific change}

```
````

For every group, include its commit count and original first commit message so the user can identify the correct message stop during rebase. Use a type prefix from `Feature`, `Fix`, `Test`, `E2E`, `Refactor`, `Chore`, or `Docs`; keep the summary to 50 characters or fewer, explain purpose and context, and list specific affected files or components.

Replace `{base-branch}` in the template with the actual base established in step 1. Copy commits oldest-first, use `pick` for each group's first commit and `s` for only that group's remaining contiguous commits. The concatenated group hashes must exactly equal the original sequence.
