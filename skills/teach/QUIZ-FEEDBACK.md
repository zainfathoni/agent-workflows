# Quiz and Feedback Rules

## Feedback loops

Skills need tight feedback loops. Use quizzes, light browser tasks, short real-world procedures, or recall prompts. Give corrective feedback immediately and record results in `NOTES.md`.

For multiple-choice quizzes, make answer choices the same number of words where possible so formatting does not leak the answer.

## Tycho inquiry

When running in Tycho and asking the user to answer a quiz or choose a next teaching direction, prefer the structured final-response `inquiry` object over markdown-only questions. Do not use `request_user_input` as the primary path unless that tool is available in the current mode.

For multiple-choice quizzes:

- create one inquiry field per question;
- use `input_type: "select"`;
- put choices in each field's `options` array;
- use stable keys such as `q1_presence_gate`;
- use `input_type: "text"` only for free-recall prompts.

After the user answers, grade each field explicitly, correct misses, and write a learning record only when the user demonstrates understanding.
