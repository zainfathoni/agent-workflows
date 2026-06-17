#!/usr/bin/env bash
#
# serve-lessons.sh — serve a /teach workspace over the tailnet (tailnet-only).
#
# Stands up the two layers the lessons need on any machine:
#   1. a local static file server (python http.server) bound to localhost, and
#   2. a persistent `tailscale serve` path mapping that proxies to it.
#
# Assumes Tailscale is installed, logged into the tailnet, and HTTPS/MagicDNS
# is already enabled (so `tailscale serve` can mint the cert).
#
# Usage:
#   serve-lessons.sh [TEACH_DIR] [PORT] [URL_PATH]
#     TEACH_DIR  directory to serve (default: current directory)
#     PORT       localhost port for the static server (default: 7374)
#     URL_PATH   tailnet path to mount it under (default: /teach)
#
set -euo pipefail

TEACH_DIR="${1:-$PWD}"
PORT="${2:-7374}"
URL_PATH="${3:-/teach}"

# Absolutize so http.server gets an unambiguous --directory regardless of CWD.
TEACH_DIR="$(cd "$TEACH_DIR" && pwd)"

# 1. Start the local static server only if nothing already holds the port.
#    Re-running is safe: a second http.server would fail to bind, so we reuse.
if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Local server already listening on :$PORT — reusing it."
else
  python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$TEACH_DIR" \
    >"/tmp/teach-serve-$PORT.log" 2>&1 &
  echo "Started http.server on 127.0.0.1:$PORT serving $TEACH_DIR (pid $!)."
fi

# 2. Map the tailnet path to the local server. `tailscale serve` config is
#    persistent and idempotent — re-setting the same mapping is a no-op.
tailscale serve --bg --set-path "$URL_PATH" "http://127.0.0.1:$PORT"

# 3. Print the reachable URL so the user can open it on any tailnet device.
#    Derive this machine's MagicDNS name from `tailscale status` rather than
#    hardcoding it, so the script is portable across machines.
# DNSName comes back fully-qualified with a trailing dot — strip it.
HOST="$(tailscale status --json | jq -r .Self.DNSName)"
HOST="${HOST%.}"
if [[ -z "$HOST" || "$HOST" == "null" ]]; then
  echo "Could not resolve this machine's MagicDNS name — is Tailscale up and logged in?" >&2
  exit 1
fi
echo "Lessons available at: https://${HOST}${URL_PATH}/ (tailnet-only)"
