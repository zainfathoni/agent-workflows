# Examples

A worked walkthrough of the three phases, using a topic from this repo: the SaveBar discard flow.

## Phase 1 — Explain step by step

**1. The form tracks dirtiness**

`app/javascript/components/components/common/polaris_form.jsx`
```jsx
const isDirty = !isEqual(initialValues, currentValues);
```
The wrapper compares snapshots to derive `isDirty`. This drives everything downstream.

**2. SaveBar mounts when dirty**

`app/javascript/routes/admin/save-bar-wrapper.tsx`
```tsx
<SaveBar open={isDirty}>
  <button variant="primary" onClick={onSave}>Save</button>
  <button onClick={onDiscard}>Discard</button>
</SaveBar>
```
Open state is driven entirely by `isDirty` — no manual show/hide.

**3. Discard forks on context**

`app/javascript/components/components/common/polaris_form.jsx`
```jsx
if (isEmbedded) {
  appBridge.dispatch(discardAction);   // App Bridge owns the modal
} else {
  showPolarisConfirmModal();           // Standalone uses Polaris
}
```
Embedded contexts skip the Polaris modal because Shopify's App Bridge already shows its own confirmation in the iframe parent.

*(Continue for 3–6 beats total, depending on topic depth.)*

## Phase 2 — Alternatives and trade-offs

- **One unified Polaris modal everywhere** — simpler code path, but produces a double-confirmation in embedded contexts where App Bridge already prompts.
- **Always go through App Bridge** — uniform behavior, but requires shimming App Bridge in standalone admin where it isn't loaded.
- **No confirmation at all** — fastest UX, but a misclick irreversibly loses user input.

The deciding constraint: standalone admin has no App Bridge runtime, so a fork was unavoidable. The current code accepts the fork in exchange for native UX in both surfaces.

## Phase 3 — Checkpoint (do NOT call the tool yet)

Post the concept inventory and wait. The user needs to re-read the explanation above before the quiz UI covers it.

> **Quiz inventory — 1 question per concept, 5 questions total:**
>
> 1. How `isDirty` is derived from snapshot comparison *(Phase 1, beat 1)*
> 2. What drives SaveBar's open/closed state *(Phase 1, beat 2)*
> 3. Why discard forks on `isEmbedded` *(Phase 1, beat 3)*
> 4. Why the "unified Polaris modal everywhere" alternative was rejected *(Phase 2)*
> 5. The constraint that forced the fork (App Bridge availability) *(Phase 2)*
>
> Reply **ready** to start the quiz, or tell me which concepts to add, drop, or merge.

Then stop. No `AskUserQuestion` call until the user replies.

## Phase 4 — Quiz (only after user says "ready")

Issue one `AskUserQuestion` call with exactly 5 questions in the same order as the inventory (positions of correct answers vary per question):

> **Q1.** What drives the SaveBar's open/closed state?
>   - A button-click handler in the form
>   - A Redux flag toggled on input change
>   - **The `isDirty` derived value from comparing snapshots**  ← correct
>   - The route loader
>
> **Q2.** When a user clicks Discard in the embedded context, who renders the confirmation?
>   - **App Bridge (in the Shopify parent frame)**  ← correct
>   - Polaris Modal inside the iframe
>   - A custom confirmation component
>   - No confirmation is shown
>
> **Q3.** Why does standalone admin use a Polaris modal instead of App Bridge?
>   - Polaris modals look better
>   - It was a historical choice nobody revisited
>   - It avoids a network round-trip
>   - **App Bridge isn't loaded outside Shopify's iframe**  ← correct

After the user answers, give one-sentence feedback per question — confirm correct picks, and for misses explain what specific misconception the distractor was probing.

---

## Example 2 — Permalink mode (for sharing)

Trigger phrase from the user: *"Explain the SaveBar discard flow for the Fizzy card I'm about to write up."*

### Setup (run once before emitting any anchors)

```bash
$ gh repo view --json nameWithOwner -q .nameWithOwner
book-that-app/bookthatapp

$ git rev-parse HEAD
aa04504091e92477a8b8dd7aacd14b83d5056fe6
```

Reuse `book-that-app/bookthatapp` and `aa04504091...` for every permalink in this explanation. Resolve once, not per beat.

### Phase 1 — Explanation with permalinks

**1. The form tracks dirtiness**

[`polaris_form.jsx`](https://github.com/book-that-app/bookthatapp/blob/aa04504091e92477a8b8dd7aacd14b83d5056fe6/app/javascript/components/components/common/polaris_form.jsx#L120-L125)

```jsx
const isDirty = !isEqual(initialValues, currentValues);
```

The wrapper compares snapshots to derive `isDirty`. *(Line numbers above are illustrative — verify against the real file before sending.)*

**2. Discard forks on context**

[`polaris_form.jsx#L215-L222`](https://github.com/book-that-app/bookthatapp/blob/aa04504091e92477a8b8dd7aacd14b83d5056fe6/app/javascript/components/components/common/polaris_form.jsx#L215-L222)

```jsx
if (isEmbedded) {
  appBridge.dispatch(discardAction);
} else {
  showPolarisConfirmModal();
}
```

### Optional combined form

For artifacts where the reader might be in their editor AND share the link later, both modes can co-exist (use sparingly):

```md
[polaris_form.jsx:218](app/javascript/components/components/common/polaris_form.jsx:218)
([permalink](https://github.com/book-that-app/bookthatapp/blob/aa04504091e92477a8b8dd7aacd14b83d5056fe6/app/javascript/components/components/common/polaris_form.jsx#L218))
```

### What changes vs Example 1

- Anchors are full URLs pinned to `aa04504091…`, not branch-relative paths.
- The same SHA is reused throughout — never resolve `HEAD` again mid-explanation, or earlier links will silently point at older code than later ones.
- The snippet inline must match the line content at the permalink target. If you re-read the file after the SHA was captured and find an edit, re-run `git rev-parse HEAD` and update every permalink in the explanation before sending.
- Phases 2 (alternatives) and 3 (quiz) are identical to Example 1 — only the anchor format differs.
