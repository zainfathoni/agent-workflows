---
name: daily-standup
description: Adds BookThatApp INFO, HELP, and FOCUS updates to Obsidian daily notes. Use with supplied status data or direct requests to update Zain's or Vlad's BTA standup.
---

# Daily Standup

Add standup updates to `log/daily/YYYY-MM-DD.md` without disturbing other daily-note content.

## Required context

Before editing a daily note, read the [BTA daily-note reference](../reference/bta-daily-note.md) in full. Treat it as authoritative for the shared schema, source handling, ownership, links, deduplication, and standup-versus-release routing. Apply the standup-specific rules below in addition to that reference.

## Classify standup items

- `[INFO]`: informational updates, including deployed-to-staging, ready-to-test, an already-raised PR, or environment availability when no specific person must act.
- `[HELP]`: review, testing, approval, or attention is needed.
- `[FOCUS]`: the main work planned for today.
- Preserve an explicit supported prefix and the user's wording. If classification or ownership remains ambiguous after applying the source precedence, ask one concise question rather than guessing.

## Format bullets

- Use one bullet per item and only the prefixes `[INFO]`, `[HELP]`, and `[FOCUS]`.
- Ticket and PR: `- [HELP] [Ticket title](ticket-url) status text - [GitHub #123](https://github.com/book-that-app/bookthatapp/pull/123)`
- PR only: `- [HELP] PR title/status - [GitHub #123](https://github.com/book-that-app/bookthatapp/pull/123)`
- Ticket only: `- [FOCUS] [Ticket title](ticket-url)`, `- [HELP] [Ticket title](ticket-url) status text`, or `- [INFO] [Ticket title](ticket-url) status text`
- Do not invent titles, statuses, or links. Only normalize spacing around links when needed.

## Process

1. Determine the target date, defaulting to today. **Complete when:** one date and target `log/daily/YYYY-MM-DD.md` path are explicit.
2. Read the required shared context, then read the entire target daily note. If it is absent, create it exactly as the shared context specifies. **Complete when:** the complete original note is known and the target exists with the required schema.
3. Collect every requested item from either input branch:
   - **Provided input:** extract updates from platform data, ticket or PR links, Trello cards, Slack text, or pasted status.
   - **Direct standup request:** use the items and owner stated by the user.
   **Complete when:** every supplied item has a working record containing its available wording, owner, status, and exact URLs.
4. Route each item using the shared standup-versus-release rule. Classify every standup item as INFO, HELP, or FOCUS. When an item routes to release, read the release skill's [selection, labeling, and formatting rules](../release/SKILL.md#select-release-items) and apply those item-specific rules without restarting its process. **Complete when:** every working record has one evidenced destination, every standup record has one supported classification, and every release record has one release label.
5. Format each item for its destination, preserving exact links and explicit supported labels, then deduplicate it according to the shared policy. Reconcile a matching older-state bullet from the other section. **Complete when:** every record is either one valid destination bullet or one identified duplicate, with all supplied URLs unchanged and no stale cross-section copy.
6. Place every remaining bullet in the correct owner's standup or release block. Preserve the existing greeting and all non-target content. **Complete when:** each non-duplicate bullet appears once in its destination owner position and a comparison with the original confirms non-target content is unchanged.
7. Read back every standup and release owner block targeted by the supplied items and check the completion criteria. **Complete when:** every criterion below passes or each failing criterion is reported as a blocker.

## Completion criteria

The task is complete only when all checks pass:

- Every requested item was considered and either added once, skipped as a duplicate, or routed to release; no item is silently omitted.
- Every added standup bullet has exactly one supported prefix and follows the applicable format.
- Zain and Vlad bullets are in their respective owner positions.
- Each supplied URL is reproduced exactly, and no title, status, owner, or link was invented.
- The greeting, required headings, existing bullets, other sections, and private notes are preserved.
- No unreleased item was placed under `## Released ✅`, and no completed shipped work was placed in standup.
