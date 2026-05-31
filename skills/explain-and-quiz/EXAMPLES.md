# Examples

A compact walkthrough of the three phases, using generic code so the format stays in focus.

## Phase 1 — Explain step by step

**1. The button delegates to a handler**

`src/components/action-button.tsx`
```tsx
<button onClick={handleSubmit}>Save</button>
```

The component does not own the workflow; it forwards the click to `handleSubmit`.

**2. The handler validates first**

`src/actions/submit.ts`
```ts
if (!isValid(input)) return showError();
return save(input);
```

Invalid input stops early. Valid input continues to persistence.

*(Continue for 3-6 beats total, depending on topic depth.)*

## Phase 2 — Alternatives and trade-offs

- **Validate in the component** — quicker to find, but duplicates rules across callers.
- **Validate in the action** — centralizes rules, but makes tests depend on action behavior.
- **Skip validation** — least code, but stores bad data.

The deciding constraint: multiple callers submit the same data, so shared validation is worth the indirection.

## Phase 3 — Checkpoint (do NOT call the tool yet)

Post the concept inventory and wait. The user needs to re-read the explanation before the quiz UI covers it.

> **Quiz inventory — 1 question per concept, 3 questions total:**
>
> 1. What the button is responsible for *(Phase 1, beat 1)*
> 2. Why validation runs before saving *(Phase 1, beat 2)*
> 3. Why shared validation was chosen *(Phase 2)*
>
> Reply **ready** to start the quiz, or tell me which concepts to add, drop, or merge.

Then stop. No `AskUserQuestion` call until the user replies.

## Phase 4 — Quiz (only after user says "ready")

Issue one `AskUserQuestion` call with questions in the same order as the inventory. Vary the position of the correct answer:

> **Q1.** What is the button responsible for?
>   - **Forwarding the click to `handleSubmit`**  ← correct
>   - Saving directly to the database
>   - Running every validation rule inline
>   - Rendering the error message

After the user answers, give one-sentence feedback per question.

---

## Example 2 — Permalink mode (for sharing)

Trigger phrase from the user: *"Explain this submit flow with permalinks."*

### Setup (run once before emitting any anchors)

```bash
$ gh repo view --json nameWithOwner -q .nameWithOwner
owner/repo

$ git rev-parse HEAD
1234567890abcdef1234567890abcdef12345678
```

Reuse `owner/repo` and `1234567...` for every permalink in the explanation. Resolve once, not per beat.

### Phase 1 — Explanation with permalinks

**1. The handler validates first**

[`submit.ts`](https://github.com/owner/repo/blob/1234567890abcdef1234567890abcdef12345678/src/actions/submit.ts#L10-L13)

```ts
if (!isValid(input)) return showError();
```

The permalink points at the exact revision being explained.

### Optional combined form

For artifacts where the reader might be in their editor and share the link later, both modes can co-exist:

```md
[submit.ts:10](src/actions/submit.ts:10)
([permalink](https://github.com/owner/repo/blob/1234567890abcdef1234567890abcdef12345678/src/actions/submit.ts#L10))
```

### What changes vs Example 1

- Anchors are full URLs pinned to `1234567...`, not branch-relative paths.
- The same SHA is reused throughout.
- The snippet must match the line content at the permalink target.
