# Fizzy Command Inventory

Load this authoritative inventory after choosing a resource/action and before constructing a command. It is the single command inventory; branch references contain operational examples rather than competing command catalogs.

## Quick Reference

| Resource | List | Show | Create | Update | Delete | Other |
|----------|------|------|--------|--------|--------|-------|
| board | `board list` | `board show ID` | `board create` | `board update ID` | `board delete ID` | `migrate board ID` |
| card | `card list` | `card show NUMBER` | `card create` | `card update NUMBER` | `card delete NUMBER` | `card move NUMBER` |
| search | `search QUERY` | - | - | - | - | - |
| column | `column list --board ID` | `column show ID --board ID` | `column create` | `column update ID` | `column delete ID` | - |
| comment | `comment list --card NUMBER` | `comment show ID --card NUMBER` | `comment create` | `comment update ID` | `comment delete ID` | - |
| step | - | `step show ID --card NUMBER` | `step create` | `step update ID` | `step delete ID` | - |
| reaction | `reaction list` | - | `reaction create` | - | `reaction delete ID` | - |
| tag | `tag list` | - | - | - | - | - |
| user | `user list` | `user show ID` | - | - | - | - |
| notification | `notification list` | - | - | - | - | - |
| pin | `pin list` | - | - | - | - | `card pin NUMBER`, `card unpin NUMBER` |

---
## Command Reference

### Identity

```bash
fizzy identity show                    # Show your identity and accessible accounts
```

### Search

Quick text search across cards. Multiple words are treated as separate terms (AND).

```bash
fizzy search QUERY [flags]
  --board ID                           # Filter by board
  --assignee ID                        # Filter by assignee user ID
  --tag ID                             # Filter by tag ID
  --indexed-by LANE                    # Filter: all, closed, not_now, golden
  --sort ORDER                         # Sort: newest, oldest, or latest (default)
  --page N                             # Page number
  --all                                # Fetch all pages
```

**Examples:**
```bash
fizzy search "bug"                     # Search for "bug"
fizzy search "login error"             # Search for cards containing both "login" AND "error"
fizzy search "bug" --board BOARD_ID    # Search within a specific board
fizzy search "bug" --indexed-by closed # Include closed cards
fizzy search "feature" --sort newest   # Sort by newest first
```

### Boards

```bash
fizzy board list [--page N] [--all]
fizzy board show BOARD_ID
fizzy board create --name "Name" [--all_access true/false] [--auto_postpone_period N]
fizzy board update BOARD_ID [--name "Name"] [--all_access true/false] [--auto_postpone_period N]
fizzy board delete BOARD_ID
```

### Board Migration

Migrate boards between accounts (e.g., from personal to team account).

```bash
fizzy migrate board BOARD_ID --from SOURCE_SLUG --to TARGET_SLUG [flags]
  --include-images                       # Migrate card header images and inline attachments
  --include-comments                     # Migrate card comments
  --include-steps                        # Migrate card steps (to-do items)
  --dry-run                              # Preview migration without making changes
```

For migration semantics, limitations, requirements, and dry-run/full examples, load [Board Migration Behavior](board-migration.md).

### Cards

#### Listing & Viewing

```bash
fizzy card list [flags]
  --board ID                           # Filter by board
  --column ID                          # Filter by column ID or pseudo: not-yet, maybe, done
  --assignee ID                        # Filter by assignee user ID
  --tag ID                             # Filter by tag ID
  --indexed-by LANE                    # Filter: all, closed, not_now, stalled, postponing_soon, golden
  --search "terms"                     # Search by text (space-separated for multiple terms)
  --sort ORDER                         # Sort: newest, oldest, or latest (default)
  --creator ID                         # Filter by creator user ID
  --closer ID                          # Filter by user who closed the card
  --unassigned                         # Only show unassigned cards
  --created PERIOD                     # Filter by creation: today, yesterday, thisweek, lastweek, thismonth, lastmonth
  --closed PERIOD                      # Filter by closure: today, yesterday, thisweek, lastweek, thismonth, lastmonth
  --page N                             # Page number
  --all                                # Fetch all pages

fizzy card show CARD_NUMBER            # Show card details (includes steps)
```

#### Creating & Updating

```bash
fizzy card create --board ID --title "Title" [flags]
  --description "HTML"                 # Card description (HTML only, not Markdown/plain text)
  --description_file PATH              # Read description from file
  --image SIGNED_ID                    # Header image (use signed_id from upload)
  --tag-ids "id1,id2"                  # Comma-separated tag IDs
  --created-at TIMESTAMP               # Custom created_at

fizzy card update CARD_NUMBER [flags]
  --title "Title"
  --description "HTML"                 # Read .description_html first; preserve structure and links
  --description_file PATH
  --image SIGNED_ID
  --created-at TIMESTAMP

fizzy card delete CARD_NUMBER
```

#### Status Changes

```bash
fizzy card close CARD_NUMBER           # Close card (sets closed: true)
fizzy card reopen CARD_NUMBER          # Reopen closed card
fizzy card postpone CARD_NUMBER        # Move to Not Now lane
fizzy card untriage CARD_NUMBER        # Remove from column, back to triage
```

**Note:** Card `status` field stays "published" for active cards. Use:
- `closed: true/false` to check if closed
- `--indexed-by not_now` to find postponed cards
- `--indexed-by closed` to find closed cards

#### Actions

```bash
fizzy card column CARD_NUMBER --column ID     # Move to column (use column ID or: maybe, not-yet, done)
fizzy card move CARD_NUMBER --to BOARD_ID     # Move card to a different board
fizzy card assign CARD_NUMBER --user ID       # Toggle user assignment
fizzy card tag CARD_NUMBER --tag "name"       # Toggle tag (creates tag if needed)
fizzy card watch CARD_NUMBER                  # Subscribe to notifications
fizzy card unwatch CARD_NUMBER                # Unsubscribe
fizzy card pin CARD_NUMBER                    # Pin card for quick access
fizzy card unpin CARD_NUMBER                  # Unpin card
fizzy card golden CARD_NUMBER                 # Mark as golden/starred
fizzy card ungolden CARD_NUMBER               # Remove golden status
fizzy card image-remove CARD_NUMBER           # Remove header image
```

#### Attachments

```bash
fizzy card attachments show CARD_NUMBER                    # List attachments
fizzy card attachments download CARD_NUMBER [INDEX]        # Download (1-based index)
  -o, --output FILENAME                                    # Output filename (single file)
```

### Columns

Boards have pseudo columns by default: `not-yet`, `maybe`, `done`

```bash
fizzy column list --board ID
fizzy column show COLUMN_ID --board ID
fizzy column create --board ID --name "Name" [--color HEX]
fizzy column update COLUMN_ID --board ID [--name "Name"] [--color HEX]
fizzy column delete COLUMN_ID --board ID
```

### Comments

```bash
fizzy comment list --card NUMBER [--page N] [--all]
fizzy comment show COMMENT_ID --card NUMBER
fizzy comment create --card NUMBER --body "HTML" [--body_file PATH] [--created-at TIMESTAMP]
fizzy comment update COMMENT_ID --card NUMBER [--body "HTML"] [--body_file PATH]
fizzy comment delete COMMENT_ID --card NUMBER
```

### Steps (To-Do Items)

Steps are returned in `card show` response. No separate list command.

```bash
fizzy step show STEP_ID --card NUMBER
fizzy step create --card NUMBER --content "Text" [--completed]
fizzy step update STEP_ID --card NUMBER [--content "Text"] [--completed] [--not_completed]
fizzy step delete STEP_ID --card NUMBER
```

### Reactions

Reactions can be added to cards directly or to comments on cards.

```bash
# Card reactions (react directly to a card)
fizzy reaction list --card NUMBER
fizzy reaction create --card NUMBER --content "emoji"
fizzy reaction delete REACTION_ID --card NUMBER

# Comment reactions (react to a specific comment)
fizzy reaction list --card NUMBER --comment COMMENT_ID
fizzy reaction create --card NUMBER --comment COMMENT_ID --content "emoji"
fizzy reaction delete REACTION_ID --card NUMBER --comment COMMENT_ID
```

| Flag | Required | Description |
|------|----------|-------------|
| `--card` | Yes | Card number (always required) |
| `--comment` | No | Comment ID (omit for card reactions) |
| `--content` | Yes (create) | Emoji or text, max 16 characters |

### Tags

Tags are created automatically when using `card tag`. List shows all existing tags.

```bash
fizzy tag list [--page N] [--all]
```

### Users

```bash
fizzy user list [--page N] [--all]
fizzy user show USER_ID
```

### Pins

```bash
fizzy pin list                                 # List your pinned cards (up to 100)
```

### Notifications

```bash
fizzy notification list [--page N] [--all]
fizzy notification read NOTIFICATION_ID
fizzy notification read-all
fizzy notification unread NOTIFICATION_ID
```

### File Uploads

```bash
fizzy upload file PATH
# Returns an envelope whose data contains:
# { "signed_id": "...", "attachable_sgid": "..." }
```

| ID | Use For |
|---|---|
| `.data.signed_id` | Card header/background images (`--image` flag) |
| `.data.attachable_sgid` | Inline images in rich text (descriptions, comments) |

---
