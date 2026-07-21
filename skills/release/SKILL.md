---
name: release
description: Records shipped BookThatApp work in Obsidian daily notes. Use with supplied release data or a direct request to update Zain's or Vlad's released items.
---

# Release

Record shipped BookThatApp work in the correct owner's `## Released ✅` block without disturbing other daily-note content.

## Required context

Before editing a daily note, read the [BTA daily-note reference](../reference/bta-daily-note.md) in full. Treat it as authoritative for the shared schema, owner placement, preservation, source precedence, exact links, deduplication, and standup-versus-release routing. Apply the release-specific rules below in addition to that reference.

## Select release items

- Include completed shipped work and production deploys.
- Exclude work only on staging, ready for testing, pending or needing review, represented only by a raised PR, or reporting environment availability. Route those items to standup as required by the shared reference.
- Route by actual status; words such as “deploy” or “PR” alone do not establish a production release.

## Label release items

Choose labels in this order:

1. Preserve the user's or source's explicit label, including `🌟 [Enhancement]`, `🐛 [Hotfix]`, or a combined label such as `🐛🌟 [Bugfix + Feature]`.
2. Otherwise map the item by meaning:
   - feature, enhancement, migration, upgrade, or new UI/flow → `🌟 [Feature]`
   - bug, fix, hotfix, customer issue, or regression → `🐛 [Bugfix]`
   - chore, cleanup, removal, cache clear, guard, or internal maintenance → `🛠️ [Chore]`

If the label or ownership remains ambiguous after applying the shared source precedence, ask one concise question rather than guessing.

## Format release bullets

- Use one bullet per released item.
- Ticket and PR: `- 🐛 [Bugfix] [Ticket title](ticket-url) - [GitHub #123](https://github.com/book-that-app/bookthatapp/pull/123)`
- Ticket only: `- 🌟 [Feature] [Ticket title](ticket-url)`
- PR only: `- 🛠️ [Chore] Title - [GitHub #123](https://github.com/book-that-app/bookthatapp/pull/123)`
- Prefer a supplied Trello linked title for current platform data: `[Trello card title](url)`.
- Preserve supplied legacy Shortcut wording, such as `[Shortcut #12345](url)` or `[Story 12345](url)`.
- Do not add prose such as “to production” unless it is part of the supplied title. Do not invent titles, labels, owners, or links.

The resulting owner blocks follow this shape; placement and empty-heading behavior are defined by the shared reference:

```md
## Released ✅

- 🌟 [Feature] [Ticket title](ticket-url) - [GitHub #123](https://github.com/book-that-app/bookthatapp/pull/123)
- 🐛 [Bugfix] [Ticket title](ticket-url)
- 🛠️ [Chore] [Ticket title](ticket-url)

### Vlad

- 🐛 [Bugfix] [Ticket title](ticket-url)

## Escalated Bugs 🐛
```

## Process

### 1. Establish the target

Determine the target date, defaulting to today. Read the shared context and the entire target daily note; create an absent note exactly as the shared reference specifies.

**Complete when:** the target path exists with the required schema and its original content is known.

### 2. Account for the input

Collect every requested item from supplied platform data, pasted release text, ticket links, PR links, or the direct request.

**Complete when:** every supplied item and its available status, owner, label, title, and URLs are represented in a working set.

### 3. Route by actual state

Apply the shared standup-versus-release rule and retain production/shipped items for release. When an item routes to standup, read the daily-standup skill's [classification and formatting rules](../daily-standup/SKILL.md#classify-standup-items) and apply those item-specific rules without restarting its process.

**Complete when:** every item is classified as release or standup with evidence from its actual status, every release has a label, and every standup item has one supported prefix.

### 4. Label and format

Apply the destination-specific label or prefix rules, format every release or standup bullet, and preserve exact links.

**Complete when:** every item has one valid destination bullet without invented metadata.

### 5. Deduplicate and place

Apply the shared deduplication policy, reconcile any matching older-state bullet in the other section, and place each remaining bullet in the correct destination owner block while preserving existing content.

**Complete when:** each supplied item appears at most once in the correct section and owner position, no stale cross-section copy remains, and all non-target content remains intact.

### 6. Verify the result

Read back every release and standup owner block targeted by the supplied items and apply the completion criteria.

**Complete when:** every criterion below passes or the unresolved item is reported as a blocker.

## Completion criteria

The task is complete only when all checks pass:

- Every requested item was considered and either added once, skipped as a duplicate, or routed to standup; no item is silently omitted.
- Every added release represents completed shipped work or a production deploy and follows one applicable bullet format.
- Every release has the source's explicit label or the correct Feature, Bugfix, or Chore mapping; combined and nonstandard explicit labels are preserved.
- Zain and Vlad bullets are in their respective owner positions, including required empty `### Vlad` headings.
- Every supplied URL and linked title or legacy Shortcut wording is preserved exactly, and no title, status, label, owner, or link was invented.
- Required headings, existing bullets, other sections, the greeting, and private notes are preserved.
- No unreleased item appears under `## Released ✅`, and no completed shipped item remains incorrectly routed to standup.
