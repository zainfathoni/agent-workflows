# Quiz and Feedback Rules

## Feedback loops

Skills need tight feedback loops. Use quizzes, light browser tasks, short real-world procedures, or recall prompts. Give corrective feedback immediately and record results in `NOTES.md`.

For multiple-choice quizzes, make answer choices the same number of words where possible so formatting does not leak the answer.

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

## Option shuffling

Shuffle option order between quiz attempts so a previously-seen or leaked answer pattern does not transfer to a retry.
