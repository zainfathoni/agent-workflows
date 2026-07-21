# Bounded Video Evidence

Read this reference only when motion, timing, or a multi-stage interaction is necessary to prove the scenario.

## Capture defaults

- Record one scenario with one assertion.
- Prefer 8–15 seconds; 30 seconds is the maximum.
- Use a 1280×720, 16:9 canvas at 25–30 fps. Place a native mobile viewport inside that canvas with caption room instead of publishing a tall social-video frame.
- Hold initial and final states for 1–2 seconds.
- For visual regressions, show labeled Before/After panels simultaneously. For lifecycles, use numbered stages such as `1/3 dirty`, `2/3 navigation blocked`, and `3/3 discarded`.
- Show a purposeful 20–24 px high-contrast cursor with a brief click ripple. Playwright recording requires an injected cursor when cursor movement is evidence.
- Bake in a short scenario/environment header and one action/result caption per stage. Pair color with text; narration and audio are optional.
- Use Playwright WebM/VP8 when it is already available. Note H.264 as the greatest-compatibility option when reviewers' browsers require it.
- Target less than 3 MB; 10 MB is the hard ceiling. Prefer video over GIF for this branch.

## Disposable Playwright recording

Record successful evidence in a disposable context rather than depending on a repository's failure-only recording setting:

```js
const context = await browser.newContext({
  viewport: { width: 1280, height: 720 },
  recordVideo: {
    dir: '/tmp/pr-e2e-video',
    size: { width: 1280, height: 720 },
  },
});
const page = await context.newPage();
const video = page.video();

// Exercise one bounded scenario and add caption/cursor overlays if needed.

await page.close();
const videoPath = await video.path();
await context.close();
```

## Playback gate

Inspect the final file at normal playback size and verify:

- the named scenario and verdict are visually clear;
- captions, route context, cursor, and clicks are visible;
- duration is 30 seconds or less and dimensions are 1280×720;
- codec and file size are known, with size below 10 MB;
- playback works in the reviewers' browser;
- the complete interaction stays inside the named scenario.

Record duration, dimensions, codec, and file size in the local draft and adjacent published PR text. Upload the video once and verify the PR renders a playable control rather than only an opaque download link.
