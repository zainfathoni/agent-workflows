# Tailscale Hosting Helper

Use this only for workspaces whose `HOSTING.md` chooses private tailnet hosting.

## Command

```bash
~/.agents/skills/teach/serve-lessons.sh [TEACH_DIR] [PORT] [URL_PATH]
# defaults: TEACH_DIR=$PWD, PORT=7374, URL_PATH=/teach
```

## What it does

1. Starts `python3 -m http.server <PORT> --bind 127.0.0.1 --directory <TEACH_DIR>` only if nothing already holds the port. The local server is ephemeral and dies on reboot/logout.
2. Sets a persistent tailnet proxy with `tailscale serve --bg --set-path <URL_PATH> http://127.0.0.1:<PORT>`.
3. Prints `https://<this-host>.<tailnet>.ts.net<URL_PATH>/`.

## Prerequisites

Tailscale must be installed, logged into the tailnet, and have HTTPS/MagicDNS enabled.

## Verification before sharing

Before handing over a tailnet lesson URL:

1. Run `tailscale serve status` and confirm `<URL_PATH>` maps to the expected local port.
2. Check at least one lesson locally with `curl -I http://127.0.0.1:<PORT>/<topic>/lessons/<lesson>.html` or the correct workspace-relative path.
3. If a Tailscale hostname is known, check the tailnet URL with `curl -I` too.
4. If the port is occupied by an old `http.server` rooted at the wrong directory, restart it against the intended teach root before sharing links.

## Stop sharing

Remove the mapping with:

```bash
tailscale serve --set-path <URL_PATH> off
```

Then kill the `http.server` process if it is still running.
