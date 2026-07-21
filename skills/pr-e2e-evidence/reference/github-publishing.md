# GitHub Evidence Publishing

Read this reference when local screenshots or videos must become GitHub-hosted PR or issue attachments.

GitHub-hosted image markup has this form:

```md
![Scenario label](https://github.com/user-attachments/assets/<uuid>)
```

GitHub documents no attachment-retention SLA, so the structured PR text and decisive stills remain the durable record.

## Browser upload flow

When Chrome DevTools is available and GitHub is authenticated:

1. Open the PR or issue conversation and find the comment editor's attachment target.
2. Upload one local media file or a small batch.
3. Wait until each `Uploading...` placeholder becomes completed Markdown with a stable `user-attachments` URL.
4. Confirm the attachment URL count increased and map each URL to its alt text or filename.
5. Extract the generated markup, clear the editor, and verify the submit button is disabled or the editor is empty.
6. Add the attachment markup to the structured `## E2E evidence` section with `gh pr edit --body-file` or the browser edit UI.
7. Verify every image renders, every video has a playable control, the new URLs are present, and the PR comment count did not increase.

The comment editor may stage uploads for the publication target selected by the main process.

Practical Chrome DevTools sequence:

```text
upload_file(uid=<attachment drop target>, filePath=<local media file>)
wait until the editor text contains `user-attachments` and no longer contains `Uploading`
repeat for each media file or small batch
read the editor text and map alt text / filename to attachment URL
clear the editor value and dispatch input/change events
update the PR body with the final grouped Markdown evidence
verify the comment count did not increase
```

After each upload, verify the attachment URL count increased before starting the next batch.

## Fallbacks

When browser upload is unavailable, choose the first acceptable option:

1. Ask the user to upload the files and return the rendered Markdown or URLs.
2. Use `gh image` or `gh-image` when already installed, or when the user accepts installation, and it can access a valid GitHub browser session token.
3. Use an external public host only with the user's explicit acceptance of its visibility and durability tradeoff.

Repository raw URLs, committed `docs/tests/` media, and notes-repository links count as final evidence only when they render reliably in the PR body or intentional comment. Mark an earlier broken or redundant comment as superseded and link to the rendered evidence. Delete a self-authored public comment only when the user explicitly requests that deletion.
