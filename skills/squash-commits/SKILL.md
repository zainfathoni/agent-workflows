---
name: squash-commits
description: Prepares a chronological squash guide and, when explicitly authorized, performs and verifies the guided Git squash. Use when consolidating related commits on a branch.
---

# Squash Commits

Prepare the guide on every run. Perform history rewriting only when the user explicitly authorizes the squash; pushing requires separate explicit authorization.

## Process

1. **Establish the range.** Determine the current branch and its actual base branch, then list the commits unique to the branch oldest-first with 10-character hashes (for example, `git log master..HEAD --format="%h %s" --reverse`). Record the exact base, branch, hashes, subjects, and count. **Complete when:** every commit in `<base>..HEAD` appears once in the recorded oldest-first sequence and every hash is exactly 10 characters.

2. **Partition the sequence.** Assign every commit to exactly one contiguous group; related commits separated by other work remain separate unless all intervening commits belong to the same group. Preserve the recorded chronological order exactly. **Complete when:** concatenating the groups reproduces the original hash sequence byte-for-byte, with no omissions, duplicates, or reordering.

3. **Create a unique guide.** Extract the ticket ID from the branch name (for example, `sc-61299` from `feature/sc-61299/...`) and choose `docs/rebases/{ticket-id}/YYYY-MM-DD.md`; if occupied, append `-1`, `-2`, and so on (first file: `2026-01-08.md`; second: `2026-01-08-1.md`; third: `2026-01-08-2.md`). Read [`reference/guide-template.md`](reference/guide-template.md) now and create the guide from it. **Complete when:** the new path is unique and the guide's rebase plan has the same ordered hashes and total count as step 1, with each group and proposed message documented.

4. **Create a local recovery point.** Create `backup/{original-branch-name}-before-rebase-{rebase-identifier}` at the current `HEAD` (for example, `git branch backup/feature/short-name-before-rebase-2026-01-08-1`). Keep it local. **Complete when:** the backup ref resolves to the pre-rebase `HEAD`.

5. **Choose the execution branch.** If squash execution is not explicitly authorized, stop after reporting the guide and backup. If authorized and the guide has one group covering the whole branch, read and follow [`reference/single-group-automation.md`](reference/single-group-automation.md). If authorized and it has multiple groups, run interactive rebase manually from the recorded base, applying the groups and prepared messages exactly. **Complete when:** either preparation-only is reported, or the chosen method matches the guide's group count and the rebase has finished.

6. **Verify the rebase.** Confirm no rebase is in progress, Git reports a clean rebase completion, and `git log <base>..HEAD --format="%h %s" --reverse` has exactly the expected number of commits in the expected group order. Confirm each resulting commit contains the intended contiguous original range. **Complete when:** the observed sequence, count, order, and contents match the guide; otherwise recover or repair before continuing.

7. **Finalize messages.** After single-group automation, amend the one resulting commit with the guide's prepared message. After a multi-group interactive rebase, verify the messages entered during that rebase and repair any mismatch through another order-preserving interactive rebase. Repeat step 6's sequence/count/content checks. **Complete when:** every resulting subject/body matches the guide and all rebase verification still passes.

8. **Publish only with authorization.** Push the rewritten code branch only when the user explicitly authorizes pushing, and use `git push --force-with-lease` (never plain force). **Complete when:** either no push was authorized and none occurred, or the authorized force-with-lease succeeds without overwriting unexpected remote work.

9. **Commit guide files in their owner repository.** After an authorized squash succeeds, read and follow [`reference/guide-repository.md`](reference/guide-repository.md). **Complete when:** only guide files created for this squash are committed in the repository that owns them; unrelated changes remain untouched. Push that guide commit only with explicit push authorization.

The chronological order established in step 1 is invariant through partitioning, guide generation, rebase, amend, and verification.
