# Screenshot Evidence

Read this reference when the chosen evidence medium is a screenshot, an interaction before/after pair, or a baseline-versus-candidate comparison.

## Capture the matching state

- Capture the reported interaction mode; only the exact widget, route, or view proves that path.
- Use the closest matching deployed route. Record environment-specific prefixes or mounting differences, such as a staging app-proxy path.
- For baseline/candidate evidence, keep viewport, scroll position, filters, date range, selected records, account, role, feature flags, and UI mode aligned. State any parity gap beside the evidence.
- For a single-environment interaction, treat the decision point as **Before** and the resulting page or state as **After**.
- Separate navigation success from downstream health. Record an unrelated destination-page failure as a separate observation.

## Build the final image

1. Crop each source to the meaningful UI while retaining enough page, store, route, or widget identity to establish context.
2. Remove blank areas, unrelated grids, footers, browser chrome, repeated content, and off-screen whitespace.
3. Combine related states into one image by default:
   - Left: `Before: <baseline or decision state>`.
   - Right: `After: <candidate or resulting state>`.
   - Add a short scenario and environment title.
4. Use action-oriented labels such as `Before: event link visible` and `After: product page opened`. Add a small note for injected containers, staging-only fixtures, or relevant environment differences.
5. Prefer restrained headers, borders, and arrows. Highlights may identify the acted-on control while leaving text and controls legible.

Keep separate screenshots when combining them would reduce readability. Label focused after-only evidence explicitly.

## Inspect before publishing

At normal review size, confirm the final image shows the claimed states, readable labels, enough route/surface context, and no stale loading state or unrelated sensitive data. Recapture a wrong state rather than forcing it into a crop. Keep raw full-size captures as temporary source material unless requested.

Use descriptive draft filenames such as `<ticket-or-pr>-<date>-<scenario>-before-after.png`. In the PR, group final images by scenario or surface, add the route or scenario above each image, and explain the claim each image supports.
