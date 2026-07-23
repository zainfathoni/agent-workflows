#!/usr/bin/env python3
"""Inspect and clean the exact Chrome process owned by this skill's probe."""

from __future__ import annotations

import argparse
import json
import os
import re
import secrets
import shutil
import signal
import stat
import subprocess
import tempfile
import time
from dataclasses import dataclass


MARKER = "--bta-dev-health-probe"
PROFILE_PATTERN = re.compile(r"--user-data-dir=(?:\"([^\"]+)\"|'([^']+)'|(\S+))")
STATE_VERSION = 1
MAX_STATE_BYTES = 4096


@dataclass(frozen=True)
class ProcessRow:
    pid: int
    ppid: int
    started_at: str
    state: str
    command: str


def process_rows() -> dict[int, ProcessRow]:
    output = subprocess.check_output(
        ["ps", "-axo", "pid=,ppid=,lstart=,stat=,command="],
        text=True,
        stderr=subprocess.DEVNULL,
        timeout=3,
    )
    rows = {}
    for line in output.splitlines():
        fields = line.strip().split(None, 8)
        if len(fields) != 9:
            continue
        try:
            row = ProcessRow(
                pid=int(fields[0]),
                ppid=int(fields[1]),
                started_at=" ".join(fields[2:7]),
                state=fields[7],
                command=fields[8],
            )
        except ValueError:
            continue
        rows[row.pid] = row
    return rows


def ancestor_chain(rows: dict[int, ProcessRow], pid: int) -> list[ProcessRow]:
    chain = []
    seen = set()
    while pid in rows and pid not in seen:
        seen.add(pid)
        row = rows[pid]
        chain.append(row)
        pid = row.ppid
    return chain


def current_amp_owner(rows: dict[int, ProcessRow]) -> ProcessRow | None:
    for row in ancestor_chain(rows, os.getpid()):
        executable = os.path.basename(row.command.split(None, 1)[0])
        if executable == "amp":
            return row
    return None


def marked_processes(
    rows: dict[int, ProcessRow], owner_amp_pid: int
) -> list[tuple[ProcessRow, str]]:
    matches = []
    for row in rows.values():
        if (
            row.state.startswith("Z")
            or MARKER not in row.command
            or "Google Chrome" not in row.command
            or not any(ancestor.pid == owner_amp_pid for ancestor in ancestor_chain(rows, row.pid))
        ):
            continue
        profile_match = PROFILE_PATTERN.search(row.command)
        if profile_match is None:
            continue
        profile = next(value for value in profile_match.groups() if value is not None)
        matches.append((row, os.path.realpath(profile)))
    return matches


def is_temporary_profile(profile: str) -> bool:
    candidate = os.path.realpath(profile)
    roots = {
        os.path.realpath(tempfile.gettempdir()),
        os.path.realpath("/tmp"),
        os.path.realpath("/private/tmp"),
        os.path.realpath("/var/folders"),
    }
    for root in roots:
        try:
            if os.path.commonpath([candidate, root]) == root and candidate != root:
                return True
        except ValueError:
            continue
    return False


def write_state(payload: dict[str, object]) -> str:
    nonce = secrets.token_hex(16)
    payload = {**payload, "run_nonce": nonce}
    fd, path = tempfile.mkstemp(
        prefix=f"bta-dev-health-browser-{nonce}-", suffix=".json"
    )
    try:
        os.fchmod(fd, 0o600)
        with os.fdopen(fd, "w") as handle:
            fd = -1
            json.dump(payload, handle, sort_keys=True)
            handle.flush()
            os.fsync(handle.fileno())
    except Exception:
        if fd >= 0:
            os.close(fd)
        os.unlink(path)
        raise
    return path


def read_state(path: str) -> dict[str, object]:
    canonical_path = os.path.realpath(path)
    temporary_root = os.path.realpath(tempfile.gettempdir())
    basename = os.path.basename(canonical_path)
    state_name = re.fullmatch(
        r"bta-dev-health-browser-([0-9a-f]{32})-[^.]+\.json", basename
    )
    if not (
        os.path.dirname(canonical_path) == temporary_root
        and state_name is not None
    ):
        raise ValueError("state file path is invalid")
    metadata = os.lstat(path)
    if (
        not stat.S_ISREG(metadata.st_mode)
        or metadata.st_uid != os.geteuid()
        or stat.S_IMODE(metadata.st_mode) != 0o600
        or metadata.st_size > MAX_STATE_BYTES
    ):
        raise ValueError("state file ownership or shape is invalid")
    with open(path) as handle:
        payload = json.load(handle)
    required = {
        "version",
        "chrome_pid",
        "chrome_started_at",
        "profile",
        "profile_nonce",
        "run_nonce",
        "owner_amp_pid",
        "owner_amp_started_at",
    }
    if not isinstance(payload, dict) or set(payload) != required:
        raise ValueError("state file fields are invalid")
    if payload["run_nonce"] != state_name.group(1):
        raise ValueError("state file nonce is invalid")
    return payload


def inspect() -> int:
    rows = process_rows()
    owner = current_amp_owner(rows)
    if owner is None:
        print(json.dumps({"status": "amp-owner-unproven"}, sort_keys=True))
        return 1
    matches = marked_processes(rows, owner.pid)
    if len(matches) != 1:
        print(
            json.dumps(
                {
                    "status": "ambiguous",
                    "marked_process_count": len(matches),
                },
                sort_keys=True,
            )
        )
        return 1

    chrome, profile = matches[0]
    temporary = is_temporary_profile(profile)
    state_file = None
    if temporary:
        state_file = write_state(
            {
                "version": STATE_VERSION,
                "chrome_pid": chrome.pid,
                "chrome_started_at": chrome.started_at,
                "profile": profile,
                "profile_nonce": os.path.basename(profile),
                "owner_amp_pid": owner.pid,
                "owner_amp_started_at": owner.started_at,
            }
        )
    print(
        json.dumps(
            {
                "status": "ready" if temporary else "persistent-profile",
                "pid": chrome.pid,
                "profile": profile,
                "state_file": state_file,
                "temporary_profile": temporary,
            },
            sort_keys=True,
        )
    )
    return 0 if temporary else 1


def cleanup(state_file: str) -> int:
    try:
        binding = read_state(state_file)
    except (OSError, ValueError, json.JSONDecodeError):
        print(json.dumps({"status": "ownership-state-invalid"}, sort_keys=True))
        return 1

    pid = binding["chrome_pid"]
    raw_profile = binding["profile"]
    if not isinstance(pid, int) or not isinstance(raw_profile, str):
        print(json.dumps({"status": "ownership-state-invalid"}, sort_keys=True))
        return 1
    profile = os.path.realpath(raw_profile)
    rows = process_rows()
    owner = current_amp_owner(rows)
    chrome = rows.get(pid)
    if not (
        binding["version"] == STATE_VERSION
        and isinstance(binding["owner_amp_pid"], int)
        and isinstance(binding["owner_amp_started_at"], str)
        and owner is not None
        and owner.pid == binding["owner_amp_pid"]
        and owner.started_at == binding["owner_amp_started_at"]
        and chrome is not None
        and chrome.started_at == binding["chrome_started_at"]
        and isinstance(binding["profile_nonce"], str)
        and binding["profile_nonce"] == os.path.basename(profile)
        and not chrome.state.startswith("Z")
        and MARKER in chrome.command
        and "Google Chrome" in chrome.command
        and any(ancestor.pid == owner.pid for ancestor in ancestor_chain(rows, chrome.pid))
        and PROFILE_PATTERN.search(chrome.command) is not None
        and os.path.realpath(
            next(
                value
                for value in PROFILE_PATTERN.search(chrome.command).groups()
                if value is not None
            )
        )
        == profile
        and is_temporary_profile(profile)
    ):
        print(json.dumps({"status": "ownership-unproven"}, sort_keys=True))
        return 1

    os.kill(pid, signal.SIGTERM)
    deadline = time.monotonic() + 8
    while time.monotonic() < deadline:
        if not any(
            row.pid == pid and not row.state.startswith("Z")
            for row in process_rows().values()
        ):
            break
        time.sleep(0.2)
    else:
        os.kill(pid, signal.SIGKILL)
        kill_deadline = time.monotonic() + 2
        while time.monotonic() < kill_deadline:
            if not any(
                row.pid == pid and not row.state.startswith("Z")
                for row in process_rows().values()
            ):
                break
            time.sleep(0.1)

    if any(
        row.pid == pid and not row.state.startswith("Z")
        for row in process_rows().values()
    ):
        print(json.dumps({"status": "process-still-running", "pid": pid}, sort_keys=True))
        return 1

    remaining_rows = process_rows()
    if marked_processes(remaining_rows, owner.pid):
        print(json.dumps({"status": "replacement-process", "pid": pid}, sort_keys=True))
        return 1

    if os.path.exists(profile):
        try:
            shutil.rmtree(profile)
        except FileNotFoundError:
            pass
    removed = not os.path.exists(profile)
    if removed:
        os.unlink(state_file)
    print(
        json.dumps(
            {"status": "clean" if removed else "profile-remains", "pid": pid},
            sort_keys=True,
        )
    )
    return 0 if removed else 1


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Manage the BTA health probe browser.")
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("inspect")
    cleanup_parser = subparsers.add_parser("cleanup")
    cleanup_parser.add_argument("--state-file", required=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.command == "inspect":
        return inspect()
    return cleanup(args.state_file)


if __name__ == "__main__":
    raise SystemExit(main())
