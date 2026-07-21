# Fizzy Example Workflows

Load the matching example when an operation spans commands: cards with steps or images, workflow/board moves, filtered search, or reactions.

## Example Workflows

### Create Card with Steps

```bash
# Create the card
CARD=$(fizzy card create --board BOARD_ID --title "New Feature" \
  --description "<p>Feature description</p>" | jq -r '.data.number')

# Add steps
fizzy step create --card $CARD --content "Design the feature"
fizzy step create --card $CARD --content "Implement backend"
fizzy step create --card $CARD --content "Write tests"
```

### Create Card with Inline Image

```bash
# Upload image
SGID=$(fizzy upload file screenshot.png | jq -r '.data.attachable_sgid')

# Create description file with embedded image
cat > desc.html << EOF
<p>See the screenshot below:</p>
<action-text-attachment sgid="$SGID"></action-text-attachment>
EOF

# Create card
fizzy card create --board BOARD_ID --title "Bug Report" --description_file desc.html
```

### Create Card with Background Image (only when explicitly requested)

```bash
# Validate file is an image
MIME=$(file --mime-type -b /path/to/image.png)
if [[ ! "$MIME" =~ ^image/ ]]; then
  echo "Error: Not a valid image (detected: $MIME)"
  exit 1
fi

# Upload and get signed_id
SIGNED_ID=$(fizzy upload file /path/to/header.png | jq -r '.data.signed_id')

# Create card with background
fizzy card create --board BOARD_ID --title "Card" --image "$SIGNED_ID"
```

### Move Card Through Workflow

```bash
# Move to a column
fizzy card column 579 --column maybe

# Assign to user
fizzy card assign 579 --user USER_ID

# Mark as golden (important)
fizzy card golden 579

# When done, close it
fizzy card close 579
```

### Move Card to Different Board

```bash
# Move card to another board
fizzy card move 579 --to TARGET_BOARD_ID
```

### Search and Filter Cards

```bash
# Quick search
fizzy search "bug" | jq '[.data[] | {number, title}]'

# Search with filters
fizzy search "login" --board BOARD_ID --sort newest

# Find recently created cards
fizzy card list --created today --sort newest

# Find cards closed this week
fizzy card list --indexed-by closed --closed thisweek

# Find unassigned cards
fizzy card list --unassigned --board BOARD_ID
```

### React to a Card

```bash
# Add reaction directly to a card
fizzy reaction create --card 579 --content "👍"

# List reactions on a card
fizzy reaction list --card 579 | jq '[.data[] | {id, content, reacter: .reacter.name}]'
```

### Add Comment with Reaction

```bash
# Add comment
COMMENT=$(fizzy comment create --card 579 --body "<p>Looks good!</p>" | jq -r '.data.id')

# Add reaction to the comment
fizzy reaction create --card 579 --comment $COMMENT --content "👍"
```

---
