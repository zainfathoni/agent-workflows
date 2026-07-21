---
name: review-clear
description: Deletes exactly one current-user PENDING PR review after an explicit cleanup request.
---

# Review Clear

Perform destructive cleanup of one draft review while preserving all submitted, public, and teammate-authored artifacts. Cleanup neither resolves threads nor publishes or submits content.

## Steps

1. **Establish identity and intent.** Read the explicit user request, resolve the PR, and obtain the authenticated GitHub login with `gh api user --jq .login`. Treat conditional cleanup of replied-to threads as requiring final-status reply validation. **Complete when the PR, exact current user, explicit deletion intent, and whether reply validation was requested are recorded without ambiguity.**

2. **Inventory reviews and protected artifacts.** Fetch all PR reviews, review comments, issue comments, and review-thread state, following pagination. Identify candidate reviews by numeric REST review ID, state, and author. Snapshot every submitted review and every public or teammate-authored comment/thread, including IDs and relevant state. Read [REFERENCE.md](REFERENCE.md#inventory-and-snapshot) for the complete REST/GraphQL inventory sequence when performing this step. **Complete when exactly one candidate and a comparison snapshot of every protected artifact are recorded; stop if candidate cardinality or ownership is unclear or not exactly one.**

3. **Validate final-status replies when requested.** For each original pending thread in the candidate review, identify the original current-user pending comment (`replyTo == null` / `in_reply_to_id == null`) and replies in that same thread. Require exactly one current-user pending reply that states exactly one `review-verify` status: `addressed`, `still-open`, `uncertain`, or `not-applicable`; explanatory text may accompany the status. Read [REFERENCE.md](REFERENCE.md#conditional-reply-validation) only when this condition applies. **Complete when every original pending thread has exactly one qualifying final-status reply, or stop with the missing, duplicate, non-pending, wrong-author, or ambiguous replies listed.**

### Deletion Eligibility Gate

Immediately before deletion, re-fetch the candidate and pass all conditions positively:

- its author login exactly equals the authenticated current-user login;
- its state exactly equals `PENDING`;
- it is the only target candidate;
- the user explicitly requested deletion of that target; and
- when final-status replies were requested, every original pending thread has exactly one qualifying current-user pending reply as defined in step 3.

**The gate passes only when all applicable conditions are evidenced from the fresh state; stop on ambiguity, failed ownership, or non-unit cardinality.**

4. **Delete the eligible review.** Only after the Deletion Eligibility Gate passes, delete its numeric review ID:

   ```bash
   gh api -X DELETE repos/{owner}/{repo}/pulls/<pr-number>/reviews/<numeric-review-id>
   ```

   **Complete when the API confirms deletion of that exact review ID; perform no other mutation.**

5. **Verify cleanup and preservation.** Re-fetch the reviews, review comments, issue comments, and review-thread state. Compare protected artifacts with the step 2 snapshot. Read [REFERENCE.md](REFERENCE.md#final-state-verification) for the post-delete query and comparison mechanic when performing this step. **Complete when the deleted review ID is absent, no current-user pending review unexpectedly remains, and every submitted review plus every public or teammate-authored artifact is unchanged; otherwise report the discrepancy without further mutation.**

Report the deleted review ID, gate evidence, and preservation verification.
