# Single-group automation

Read this file only when step 5 of [`../SKILL.md`](../SKILL.md) is explicitly authorized and one group covers every commit in the branch range.

Automate the interactive rebase with:

```bash
GIT_SEQUENCE_EDITOR="sed -i '' -e '2,\$s/^pick /s /'" \
GIT_EDITOR=true \
git rebase -i "$base"
```

Set `base` to the established base branch or merge-base before running the command. The editor preserves chronological order and changes only later `pick` lines to `s`; `GIT_EDITOR=true` temporarily accepts Git's combined message. Proceed to the verification and amend steps in the main process. A multi-group guide requires manual interactive rebase instead.
