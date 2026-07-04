# Quiz and Feedback Rules

## Feedback loops

Skills need tight feedback loops. Use quizzes, light browser tasks, short real-world procedures, or recall prompts. Give corrective feedback immediately and record results in `NOTES.md`.

For multiple-choice quizzes, make answer choices the same number of words where possible so formatting does not leak the answer.

Mechanism lessons embed an **in-page quiz widget**: radio options with immediate corrective feedback on submit, no page reload, self-contained over `file://`. All option-position and leak rules below apply to widget quizzes too. Then mirror a *fresh variant* (not the same questions) in chat for grading — the widget builds fluency; only the chat quiz is evidence for a learning record.

## Tycho inquiry

When running in Tycho and asking the user to answer a quiz or choose a next teaching direction, use the structured final-response `inquiry` object **and** present the questions as plain Markdown in the same reply. The `inquiry` select fields are the preferred answer mechanism, but they may silently fail to render — the Markdown version ensures the learner always sees the quiz.

For multiple-choice quizzes:

- create one inquiry field per question;
- use `input_type: "select"`;
- put choices in each field's `options` array;
- use stable keys such as `q1_presence_gate`;
- use `input_type: "text"` only for free-recall prompts.

Always mirror the same questions and options in plain Markdown below (or above) the inquiry block. The Markdown version is a fallback display, not a separate answer path — if the learner answers via text, accept that too and grade it.

After the user answers, grade each field explicitly, correct misses, and write a learning record only when the user demonstrates understanding.

## Answer-format examples must not leak the key

When showing the learner how to format their answers (e.g. "answer with the letters"), **never** use a worked example that could coincide with the real answer key. Prefer one of:

- A neutral placeholder: `1<letter> 2<letter> 3<letter> …` or `Q1: A/B/C/D`
- No example at all — if the select fields are rendered, no format instruction is needed

When the `inquiry` select fields are used, omit any free-text format example entirely; the dropdowns make it unnecessary and the example is the only vector for a key leak.

If a free-text fallback is unavoidable (non-Tycho context), construct the example so at least one position deliberately differs from the correct answer.

## Option shuffling and answer position

- **Never anchor the correct option in the same position.** Do not place the key first (or any fixed slot) across the questions of a quiz. A constant position is itself a leak — the learner can pass by pattern, and the score proves nothing. Before sending a multi-question quiz, deliberately scatter the correct options across positions.
- Shuffle option order between quiz attempts so a previously-seen or leaked answer pattern does not transfer to a retry.
- This is distinct from the `AskUserQuestion` tool's "put the recommended option first" convention, which applies only to **recommendation** prompts. In an **assessment** quiz there is no recommended option to surface — keep the two uses separate.
