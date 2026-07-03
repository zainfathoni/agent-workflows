---
name: daily-standup
description: Adds BookThatApp daily standup entries to Obsidian daily notes from the given platform or user-provided links. Use when asked to update today's BTA standup, add INFO/HELP/FOCUS items, or record Vlad's daily status.
---

# Daily Standup

Update `log/daily/YYYY-MM-DD.md` with BTA daily standup entries using the provided platform source or user-provided ticket/PR links.

## When to use

Use this skill when the user asks to:

- add today's daily standup entries
- update the BTA standup from a platform, ticket list, Trello card, GitHub PR, Slack text, or pasted status
- add `[INFO]`, `[HELP]`, `[FOCUS]`, or Vlad standup items to `log/daily/YYYY-MM-DD.md`

## Source of truth

1. The user's provided platform data, pasted status, ticket links, or PR links.
2. The existing `log/daily/YYYY-MM-DD.md` file for today's format and placement.
3. Recent daily notes only if today's file is missing or the section structure is unclear.

Do not query external systems unless the user explicitly provides the platform workflow or asks you to use an available CLI/API. Preserve links exactly as given.

## Daily note structure

Use this BTA structure:

```md
---
date: YYYY-MM-DD
tags:
  - webstreet/bta
---
# BTA

## Daily Standup

🌥️️️ Good afternoon, here's my update for today:

- [INFO] ...
- [HELP] ...
- [FOCUS] ...

### Vlad

- ...

## Released ✅

### Vlad

## Escalated Bugs 🐛

## Private Notes 📝
```

If the file already exists, preserve all non-target content and only add/update the relevant bullets.

## Workflow

1. Determine the target date; default to today.
2. Read `log/daily/YYYY-MM-DD.md`.
3. If the file does not exist, create it with the structure above.
4. Extract entries from the provided platform data:
   - Informational status updates become `[INFO]` bullets, especially deployed-to-production, deployed-to-staging, ready-to-test, already-raised-PR, or environment availability updates that do not require a specific person to act.
   - Items needing review, testing, approval, or attention become `[HELP]` bullets.
   - Items planned as the main work for today become `[FOCUS]` bullets.
   - Completed shipped work belongs under `## Released ✅`, not `## Daily Standup`.
   - Teammate entries for Vlad belong under `### Vlad` in the relevant section.
5. Preserve Trello, GitHub, Slack, Zendesk, and legacy Shortcut links exactly.
6. Deduplicate against existing bullets by matching ticket/PR URLs and item titles.
7. Insert Zain standup bullets between the greeting line and `### Vlad`.
8. Insert Vlad standup bullets under the `### Vlad` subsection before `## Released ✅`.
9. Keep section headings present even when empty.

## Formatting rules

- Use one bullet per item.
- Keep the existing greeting line if present.
- Supported standup prefixes are `[INFO]`, `[HELP]`, and `[FOCUS]`.
- Use the exact status labels supplied by the user when they are already `[INFO]`, `[HELP]`, or `[FOCUS]`.
- Preserve the user's wording when the prefix is already supplied; only normalize spacing around links if needed.
- If an item includes both a ticket and PR, format it like:
  `- [HELP] [Ticket title](ticket-url) status text - [GitHub #123](https://github.com/book-that-app/bookthatapp/pull/123)`
- If only a PR is supplied, use:
  `- [HELP] PR title/status - [GitHub #123](https://github.com/book-that-app/bookthatapp/pull/123)`
- If only a ticket is supplied, use:
  `- [FOCUS] [Ticket title](ticket-url)`, `- [HELP] [Ticket title](ticket-url) status text`, or `- [INFO] [Ticket title](ticket-url) status text`
- Do not invent ticket titles, status, or links. Ask one concise question if classification or ownership is ambiguous.

## Verification

After editing, read the changed daily note section and verify:

- The requested bullets appear once.
- Zain and Vlad entries are in the correct subsection.
- Existing content outside the target section is preserved.
