# Board Migration Behavior

Load this reference before migrating a board between accounts. Use the command syntax in [the command inventory](command-inventory.md#board-migration).

**What gets migrated:**
- Board with same name
- All columns (preserving order and colors)
- All cards with titles, descriptions, timestamps, and tags
- Card states (closed, golden, column placement)
- Optional: header images, inline attachments, comments, and steps

**What cannot be migrated:**
- Card creators (become the migrating user)
- Card numbers (new sequential numbers in target)
- Comment authors (become the migrating user)
- User assignments (team must reassign manually)

**Requirements:** You must have API access to both source and target accounts. Verify with `fizzy identity show`.

```bash
# Preview migration first
fizzy migrate board BOARD_ID --from personal --to team-account --dry-run

# Basic migration
fizzy migrate board BOARD_ID --from personal --to team-account

# Full migration with all content
fizzy migrate board BOARD_ID --from personal --to team-account \
  --include-images --include-comments --include-steps
```
