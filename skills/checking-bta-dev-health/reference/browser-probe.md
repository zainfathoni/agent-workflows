# BTA Development Health Browser Probe

Use this branch only after the unfinished-work inventory names the required URLs or marks a surface deferred.

## Temporary-profile gate

Use the bundled `bta-dev-health-browser` Chrome DevTools MCP server for all required surfaces. Its configuration launches visible Chrome with `--isolated=true`, a probe marker, sensitive-header redaction, and no usage/CrUX reporting. Do not substitute a globally configured browser server.

Call its page-list tool once to launch Chrome, then resolve this skill directory and record the exact probe-owned Chrome PID and temporary profile:

```bash
python3 "$skill_dir/scripts/probe-browser-session.py" inspect
```

Continue only when the helper reports exactly one marked Chrome process beneath the current Amp process, a temporary profile, and a mode-0600 ownership state file. Retain that state-file path for cleanup. Ambiguous, persistent, unknown, or unrelated browser ownership makes the browser branch `needs-owner` without exposing regular browsing state.

An isolated profile intentionally has no persisted Google or Shopify session. Open it visibly and allow the owner to complete login, MFA, CAPTCHA, and account or tenant/store selection for this run. Readiness becomes `ready` only after that owner-assisted bootstrap and the checks below pass in the same disposable session; until then it is `needs-owner`. A missing URL is also `needs-owner`. Never extract, print, persist, or replay cookies, tokens, headers, credentials, account identity, document text, or merchant/customer data.

## One-profile sequence

Use the same temporary profile and a separate tab for each required surface:

1. **Google Docs comments.** Navigate to the approved document URL. Verify the document is authorized and the comment control/pane opens with existing comments visible. Read only enough UI state to prove comment access. Keep editors empty and leave comments, suggestions, resolutions, and document content unchanged.
2. **Shopify embedded staging.** Navigate through the approved staging/admin URL. Verify the authenticated Shopify shell, expected embedded app frame, and target surface load without an access-denied, login, application, or frame error. Perform a non-mutating interaction only when the unfinished-work inventory names its control and expected reversible result; otherwise the authenticated frame load is the result. Leave forms and save controls untouched.
3. **Full-page staging.** Navigate to the approved direct staging URL. Verify the expected full-page app surface loads outside the embedded shell and is not a login, permission, server-error, or blank page. Perform a non-mutating interaction only when the inventory names one.

For each surface, inspect the accessibility snapshot plus console and failed network-request summaries. Record only status categories and counts; redact URLs beyond scheme/host/route shape when they contain tenant, store, document, or customer identifiers. Do not save screenshots, traces, downloads, or browser storage by default.

## Cleanup gate

Close every tab created by the probe, leaving unrelated tabs untouched. Use the ownership state returned by `inspect` for cleanup:

```bash
python3 "$skill_dir/scripts/probe-browser-session.py" cleanup \
  --state-file "$browser_state_file"
```

The helper revalidates the per-run receipt nonce, state-file owner/mode, current Amp owner, Chrome PID/start identity, ancestor chain, marker, command-bound random profile, and temporary-root containment before stopping that exact Chrome process and removing only its disposable profile and state file. A process/profile that cannot be proven probe-owned remains untouched and makes cleanup `needs-owner`.

The browser branch is complete only when every required surface has a result and both process and profile cleanup are proven. Authentication success in this disposable profile demonstrates readiness for the check; it does not authorize preserving or exporting that session.
