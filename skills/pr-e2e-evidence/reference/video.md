# Bounded Video Evidence

Read this reference only when motion, timing, or a multi-stage interaction is necessary to prove the scenario.

## Capture defaults

- Record one scenario with one assertion.
- Prefer 8–15 seconds; 30 seconds is the maximum.
- Use a 1280×720, 16:9 canvas at 25–30 fps. Place a native mobile viewport inside that canvas with caption room instead of publishing a tall social-video frame.
- Hold initial and final states for 1–2 seconds.
- For visual regressions, show labeled Before/After panels simultaneously. For lifecycles the UI does not name clearly, describe numbered stages such as `1/3 dirty`, `2/3 navigation blocked`, and `3/3 discarded` in adjacent prose or non-obstructive labels.
- Show a purposeful 20–24 px high-contrast cursor with a brief click ripple. Playwright recording requires an injected cursor when cursor movement is evidence.
- Prefer a clean native-UI recording with the scenario, environment, trigger, and verdict in adjacent PR prose. Add in-video labels only when the UI cannot communicate the stage itself, and place them where they never cover controls, notifications, or results.
- Use Playwright WebM/VP8 when it is already available. Note H.264 as the greatest-compatibility option when reviewers' browsers require it.
- Target less than 3 MB; 10 MB is the hard ceiling. Prefer video over GIF for this branch.

## Capture ownership

Use Playwright `recordVideo` as the live browser recorder. Use FFmpeg only after Playwright finalizes the WebM—for trimming, caption overlays, redaction, or compression. This separation keeps browser timing and viewport capture deterministic and avoids desktop/window-recorder failures.

Record successful evidence in a disposable context rather than depending on a repository's failure-only recording setting. Retain `page.video()` immediately, close the page to finalize the recording, then save the finalized video:

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
await video.saveAs('/tmp/pr-e2e-video/scenario.webm');
await context.close();
```

When the scenario needs an existing authenticated Chrome session, launch a task-private profile clone instead of reusing a live profile directly:

```js
const context = await chromium.launchPersistentContext(privateProfilePath, {
  channel: 'chrome',
  headless: true,
  viewport: { width: 1280, height: 720 },
  recordVideo: {
    dir: '/tmp/pr-e2e-video',
    size: { width: 1280, height: 720 },
  },
});
```

Keep the private profile outside evidence artifacts, logs, and the repository; remove it after capture. A development environment that authenticates fresh browser contexts does not need a profile clone.

If FFmpeg lacks `drawtext`, render caption cards as PNGs with Pillow and apply them with the `overlay` filter. Preserve the raw Playwright recording until the annotated output passes the playback gate.

## Composition gate

Inspect a decoded frame before the full run. The application—not a recorder background, caption band, empty footer region, or window chrome—must fill the intended canvas while the action and result remain visible.

When a lower band appears, determine its source before changing the media:

- compare the Playwright viewport and `recordVideo.size` dimensions;
- inspect a direct page screenshot and the relevant DOM/computed layout;
- compare headless and headful rendering when browser mode can change layout.

Matching dimensions rule out recorder padding but do not make a poor composition acceptable: an application-native footer or background still fails when it crowds or hides the evidence. Reframe the live page—viewport, scroll position, or responsive layout—then recapture. Do not cover the band with another overlay, replace the page with a freeze frame, or crop away the interaction.

## Temporal UI gate

Frame rate does not make a short-lived notification readable. Make the real interaction observable and sequence it so each claimed native state is independently visible:

1. Arm DOM, network, and console observation before the action.
2. Perform the real action and require its mutation response and native success state.
3. Let the success notification remain readable and clear before an explicit auxiliary trigger.
4. Fire the deterministic trigger once, then require its genuine request and native result.

Gate incidental events during the mutation so they cannot masquerade as the explicit trigger. Never synthesize a toast or reuse a captured frame as live video. If two native notifications overlap, fix the trigger timing and recapture.

## Playback gate

Inspect the final file at normal playback size and verify:

- the named scenario and verdict are visually clear;
- required route context, cursor, clicks, and any chosen annotations are visible;
- duration is 30 seconds or less and dimensions are 1280×720;
- codec and file size are known, with size below 10 MB;
- playback works in the reviewers' browser;
- the complete interaction stays inside the named scenario.
- each claimed transient state is readable without overlap or obstruction;
- no lower band, footer, crop, annotation, or recorder artifact hides or crowds the action or result.

Inspect codec, dimensions, frame rate, duration, and size before publication:

```bash
ffprobe -v error \
  -show_entries format=filename,duration,size:stream=codec_name,width,height,r_frame_rate \
  -of compact=p=0:nk=1 \
  /tmp/pr-e2e-video/scenario.webm
```

Record those properties in the local draft and adjacent published PR text. Review full playback and a chronological 1 fps contact sheet in addition to metadata; require separate cells for every claimed before, action, and result state. Upload the video once and verify the PR renders a playable control rather than only an opaque download link.
