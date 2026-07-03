---
name: release
description: Adds BookThatApp released items to Obsidian daily notes from provided platform data, tickets, or PR links. Use when asked to record releases, shipped work, production deploys, or Vlad's released items in today's daily note.
---

# Release

Update the `## Released ✅` section in `log/daily/YYYY-MM-DD.md` with BTA release entries from the provided platform data, ticket links, PR links, or pasted release text.

## When to use

Use this skill when the user asks to:

- add released or shipped items to today's daily note
- record production deploys as release bullets
- add Vlad's released items
- convert platform/ticket/PR data into `## Released ✅` entries

## Source of truth

1. The user's provided platform data, pasted release notes, ticket links, or PR links.
2. The existing `log/daily/YYYY-MM-DD.md` structure and nearby release format.
3. Recent daily notes only if today's release section is missing or unclear.

Do not query external systems unless the user explicitly provides the platform workflow or asks you to use an available CLI/API. Preserve links exactly as given.

## Daily release structure

Use this placement inside the BTA section:

```md
## Released ✅

- 🌟 [Feature] [Ticket title](ticket-url) - [GitHub #123](https://github.com/book-that-app/bookthatapp/pull/123)
- 🐛 [Bugfix] [Ticket title](ticket-url)
- 🛠️ [Chore] [Ticket title](ticket-url)

### Vlad

- 🐛 [Bugfix] [Ticket title](ticket-url)

## Escalated Bugs 🐛
```

If there are no Zain releases, keep `### Vlad` directly under `## Released ✅`. If there are no Vlad releases, keep the `### Vlad` heading empty.

## Workflow

1. Determine the target date; default to today.
2. Read `log/daily/YYYY-MM-DD.md`.
3. If the daily note does not exist, create the standard BTA daily structure with `## Released ✅`, `### Vlad`, `## Escalated Bugs 🐛`, and `## Private Notes 📝`.
4. Extract release entries from the provided data:
   - Production deploys and shipped work belong in `## Released ✅`.
   - Items only deployed to staging, ready for testing, pending review, or needing review belong in daily standup (`[INFO]` or `[HELP]`), not releases.
   - Teammate releases for Vlad belong under the `### Vlad` subsection inside `## Released ✅`.
5. Classify each release item:
   - `feature`, `enhancement`, migration, upgrade, new UI/flow -> `🌟 [Feature]`
   - bug, fix, hotfix, customer issue, regression -> `🐛 [Bugfix]`
   - chore, cleanup, removal, cache clear, guard, internal maintenance -> `🛠️ [Chore]`
   - preserve explicit labels from the user or source, including `🌟 [Enhancement]`, `🐛 [Hotfix]`, or combined labels like `🐛🌟 [Bugfix + Feature]`.
6. Preserve Trello, GitHub, Slack, Zendesk, and legacy Shortcut links exactly.
7. Deduplicate against existing release bullets by matching ticket/PR URLs and item titles.
8. Insert Zain release bullets between `## Released ✅` and `### Vlad`.
9. Insert Vlad release bullets under `### Vlad` before the next `##` heading.
10. Preserve all other sections and private notes.

## Formatting rules

- Use one bullet per released item.
- Preferred format with ticket and PR:
  `- 🐛 [Bugfix] [Ticket title](ticket-url) - [GitHub #123](https://github.com/book-that-app/bookthatapp/pull/123)`
- Preferred format with only ticket:
  `- 🌟 [Feature] [Ticket title](ticket-url)`
- Preferred format with only PR:
  `- 🛠️ [Chore] Title - [GitHub #123](https://github.com/book-that-app/bookthatapp/pull/123)`
- Preserve legacy Shortcut wording already present in source material, such as `[Shortcut #12345](url)` or `[Story 12345](url)`.
- Prefer Trello linked titles for current platform data when available: `[Trello card title](url)`.
- Do not add prose like "to production" to the title unless it is part of the provided source title.
- Do not invent item titles, categories, owners, or links. Ask one concise question if classification or ownership is ambiguous.

## Verification

After editing, read the changed `## Released ✅` block and verify:

- Each requested release appears once.
- Zain and Vlad entries are in the correct subsection.
- Items not actually released were not moved into the release section.
- Existing content outside the release block is preserved.
