---
name: team-review-resolve
description: Resolves an explicitly scoped set of teammate-visible PR review threads already classified ready-to-resolve. Use when asked to resolve named thread IDs or all ready-to-resolve threads.
---

# Team Review Resolve

Resolve one explicit scope: named thread IDs, or `all ready-to-resolve threads`. A thread is eligible only when [`review-verify`](../review-verify/SKILL.md) classified its concern `addressed` and it is an identifiable, teammate-visible, currently unresolved public thread. CI alone is insufficient evidence; uncertain, partial, and still-open concerns remain unresolved.

## Steps

1. **Fix the requested scope.** Record the PR and either the exact thread IDs named by the user or the literal scope `all ready-to-resolve threads`. Treat other wording or a verification-only request as non-mutating until explicit scope is obtained. **Complete when the resolve set is expressed in exactly one of those two forms and every requested target has a stable thread ID.**

2. **Re-read and qualify every target.** Query GitHub GraphQL for each target's `id`, `isResolved`, visibility, and comments, and match it to its `review-verify` concern record. Apply the eligibility predicate above at mutation time. A pre-resolved target is a skip, not an eligible mutation. **Complete when every requested target is either eligible or assigned a concrete skip reason, with current GraphQL state and verification evidence recorded.**

   ```bash
   REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
   OWNER=${REPO%/*}
   NAME=${REPO#*/}
   gh api graphql --paginate -F owner="$OWNER" -F repo="$NAME" -F number=<pr-number> -f query='query($owner:String!, $repo:String!, $number:Int!, $endCursor:String) {
     repository(owner:$owner, name:$repo) {
       pullRequest(number:$number) {
         reviewThreads(first:100, after:$endCursor) {
           nodes {
             id isResolved isOutdated
             comments(first:100) {
               nodes { id body author { login } pullRequestReview { state author { login } } }
               totalCount
               pageInfo { hasNextPage endCursor }
             }
           }
           pageInfo { hasNextPage endCursor }
         }
       }
     }
   }'
   ```

   Reliable, complete GraphQL thread state and a non-`PENDING` owning review are mutation prerequisites. REST may aid inspection but cannot establish exact resolution state or supply `resolveReviewThread` node IDs; when GraphQL state, visibility, or pagination is unavailable or ambiguous, classify affected targets as failed and make no mutation.

3. **Post only explicitly requested public replies.** If the user requested replies, post a concise evidence note to each eligible target before resolution; otherwise post none. Keep the reply factual, for example: `Verified addressed. Evidence: <targeted command or browser scenario and result>.` **Complete when each eligible target has either the requested public reply confirmed or an explicit no-reply instruction recorded; a reply failure is recorded before deciding whether that target can proceed.**

4. **Resolve eligible targets.** Mutate each eligible thread independently with `resolveReviewThread`; preserve all public review history and leave every pending review untouched. **Complete when every eligible target has a mutation response or a recorded failure, without deleting comments or submitting, editing, or deleting pending reviews.**

   ```bash
   gh api graphql \
     -f query='mutation($thread: ID!) {
       resolveReviewThread(input: { threadId: $thread }) {
         thread { id isResolved }
       }
     }' \
     -f thread='<thread-node-id>'
   ```

5. **Verify and report the full scope.** Re-read `isResolved` through GraphQL for every requested target, including skips and mutation failures. Report each ID as `resolved`, `skipped: <reason>`, or `failed: <reason>`; a successful mutation response without a confirming re-read is failed verification, not resolved. **Complete when every requested target appears exactly once in the report and every `resolved` result has a fresh `isResolved: true` observation.**

## New Findings

Resolution does not draft feedback. If a new concern emerges, leave the current resolution scope unchanged and use [`team-review`](../team-review/SKILL.md) for teammate PR feedback or [`self-review`](../self-review/SKILL.md) for the author's own PR feedback.
