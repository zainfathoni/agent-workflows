---
name: explain-and-quiz
description: Explain a topic with codebase references, PR review context when applicable, snippets, alternatives, and trade-offs, then quiz the user with AskUserQuestion. Use when the user asks to explain, walk through, teach, or quiz a codebase topic, change, design, or PR.
---

# Explain and Quiz

Teach a concept, change, or design by walking through actual code, comparing it to alternatives, and verifying understanding with an interactive quiz.

## When to use

- User asks "how does X work?", "explain Y", or "walk me through Z"
- User wants to internalize the trade-offs behind a design choice
- After implementing something non-trivial and the user wants to learn it deeply
- The target is a PR and existing pending or posted review feedback should inform the explanation

## Workflow

### PR targets: include review context

When the target is a pull request, treat existing review feedback as part of the teaching material, not as separate background.

- Read pending and posted reviews before writing the explanation.
- Include current-user PENDING review bodies/comments, submitted reviews, inline review comments, and PR conversation comments when they clarify the design, trade-offs, risks, or unresolved questions.
- Do not submit, delete, resolve, or publicly reply to review content as part of this skill.
- If pending inline comments are not visible through one endpoint, say that explicitly and use the available pending review body plus visible comments as the evidence.
- Map each review concern that affects the explanation to a beat, an alternative, a trade-off, or a quiz concept. Do not silently omit review concerns that change what the user needs to understand.

Useful PR review context commands:

```bash
gh pr view <pr-number> --comments --json number,title,headRefName,baseRefName,author,url,comments,reviews,latestReviews,reviewDecision,statusCheckRollup
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate
gh api repos/{owner}/{repo}/pulls/<pr-number>/comments --paginate
```

To find current-user pending reviews explicitly:

```bash
ME=$(gh api user --jq .login)
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate \
  | jq --arg me "$ME" '.[] | select(.state=="PENDING" and .user.login==$me) | {id,node_id,user:.user.login,body,commit_id}'
```

### 1. Explain step by step with code

- Identify the 3–6 key beats of the topic. Each beat = one concrete idea.
- For PR targets, include review-driven beats when pending or posted review feedback exposes a concern, trade-off, or design question the user needs to understand.
- For each beat, anchor it to a real file (see "Anchor modes" below).
- Show the relevant snippet inline (5–15 lines max). Excerpt, don't dump.
- Order beats by causality: what triggers what, in execution order.

### 2. Discuss alternatives and trade-offs

- Name 2–3 alternative approaches that were viable.
- For each, state the trade-off in one line: what it gains, what it costs.
- Call out the constraint in *this* codebase that made the current choice win.

### 3. Quiz checkpoint — confirm exhaustiveness, then wait

Do **not** fire `AskUserQuestion` yet. The quiz UI covers the explanation, so the user needs a chance to re-read it and to verify the quiz actually covers everything that matters.

Emit a checkpoint message with two parts:

**a) Concept inventory.** Enumerate every testable idea from Phases 1 and 2 as a numbered list. For PR targets, include every review concern that shaped the explanation or trade-off discussion. Each item is one phrase, mapped to the beat it came from. Example:

```
Quiz will cover (1 question per concept = 5 questions):
  1. What the button delegates to (Phase 1, beat 1)
  2. Why validation runs before saving (Phase 1, beat 2)
  3. What the shared action centralizes (Phase 1, beat 3)
  4. The trade-off vs the rejected "validate in every component" alternative (Phase 2)
  5. The constraint in this codebase that decided the choice (Phase 2)
```

**b) Explicit prompt.** End with: *"Reply **ready** to start the quiz, or tell me which concepts to add, drop, or merge."* Then stop — do not call `AskUserQuestion` until the user signals.

Rules for the inventory:

- **1 concept → 1 question.** Quiz length is determined by concept count, never picked arbitrarily. If the inventory has 6 items, the quiz has 6 questions.
- **No concept gets folded into "background context"** unless the user explicitly drops it. Exhaustiveness is the user's call, not yours.
- If the inventory exceeds ~8 items, ask the user whether to split into rounds rather than silently trimming.

### 4. Quiz with AskUserQuestion (after user signals ready)

- Send a single `AskUserQuestion` call with exactly N questions where N = inventory size after the user's edits.
- Each question maps 1:1 to a numbered inventory item — preserve the order so the user can trace each question back to the explanation.
- Each question has 3–4 plausible options. Wrong options should be **defensibly wrong**, not silly — they test a specific misconception.
- Rotate the correct answer's position across questions (see "Avoiding position bias").
- After the user answers, give one sentence of feedback per question — what was right, what each distractor was testing.

## Anchor modes

Two ways to point at code. Pick based on where the explanation will live.

### Default — local refs (live conversation)

Format: `path/to/file.ext:line` rendered as a markdown link, e.g. `[submit.ts:10](src/actions/submit.ts:10)`.

- Clickable in Claude Code; opens directly in the user's editor.
- Fast, offline, no network round-trip.
- Drifts when lines move — fine for ephemeral conversation.

### Opt-in — GitHub permalinks (shareable artifacts)

Switch to permalinks when the user signals the explanation will outlive the working tree: phrases like "for the PR", "for sharing", "send this to the team", or when writing into a doc/comment that will be read later.

Format: `https://github.com/<owner>/<repo>/blob/<sha>/<path>#L<line>` (or `#L<start>-L<end>` for a range).

Rules:

1. **Pin to a commit SHA, never a branch.** Resolve once at the start of the explanation:

   ```bash
   git rev-parse HEAD
   ```

   Reuse that SHA for every permalink in this explanation so all anchors stay consistent.

2. **Resolve the remote owner/repo** with `gh repo view --json nameWithOwner -q .nameWithOwner` (or read `git remote get-url origin`). Do not hardcode.

3. **Verify before linking.** The snippet shown in the explanation must match the line at the permalink. If the file was edited after the SHA was captured, re-resolve the SHA — never emit a permalink whose line content you haven't just read.

4. **Both modes is fine** for high-stakes explanations: local ref for in-editor navigation, permalink in parentheses for the durable artifact. Don't double-link routinely — it's noise.

## Avoiding position bias

The model defaults to placing the correct/recommended option first. Counter it with an explicit pre-emit self-check before calling `AskUserQuestion`:

1. **Hard rule:** the correct answer for Q1 must NOT be at position A. Pick B, C, or D.
2. **Spread rule:** across the full question set, correct answers must occupy at least 2 distinct positions. With 3+ questions, at least 3 distinct positions.
3. **Private self-check (NEVER printed):** before emitting the tool call, verify the correct-answer index for each question *in your own reasoning only* — e.g. `Q1=C, Q2=A, Q3=D`, which is an internal note and must never appear in a message to the user. If rules 1 or 2 fail, swap option ordering and recheck. Do not call the tool until the check passes.
4. **Do not leak the answer key — two forbidden failure modes:**
   - **The position map.** Never print the self-check, correct-answer indexes, or phrasing like "Q1=C" / "correct answer placed at C" in any message *before or during* the quiz — not even as a "transparency" note. If you reference the check at all, say only "self-check passed". (Real leak: a quiz announced the position map before each round and handed over the full key.)
   - **The example-string collision.** When giving a format hint for inline/fallback answering, use a neutral placeholder such as `1?, 2?, 3?, 4?` and verify its letters do NOT coincide with the real key. (Real leak: an "e.g. 1C 2D 3B 4A" hint matched 3 of 4 answers.)

   Root principle for both: anything visible before the user answers must not encode which option is correct — not its text, not its letter, not its position. The user sees only questions and options until they have answered.
5. **No tells:** keep correct options the same length and specificity as distractors — never the longest or most-qualified option by default.

## See also

- [EXAMPLES.md](EXAMPLES.md) — full worked example of all three phases against this codebase
