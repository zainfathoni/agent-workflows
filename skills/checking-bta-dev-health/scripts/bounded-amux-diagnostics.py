#!/usr/bin/env python3
"""Run only the BTA health skill's bounded amux/Amp diagnostics."""

from __future__ import annotations

import argparse
import json
import os
import signal
import subprocess
import sys
import threading
from typing import Sequence


DEADLINE_SECONDS = 30


def process_shape(root_pid: int) -> str:
    """Classify descendants without returning private command output."""
    try:
        output = subprocess.check_output(
            ["ps", "-axo", "pid=,ppid=,command="],
            text=True,
            stderr=subprocess.DEVNULL,
            timeout=2,
        )
    except (OSError, subprocess.SubprocessError):
        return "other"

    rows: list[tuple[int, int, str]] = []
    for line in output.splitlines():
        fields = line.strip().split(None, 2)
        if len(fields) != 3:
            continue
        try:
            rows.append((int(fields[0]), int(fields[1]), fields[2]))
        except ValueError:
            continue

    descendants = {root_pid}
    changed = True
    while changed:
        changed = False
        for pid, parent, _ in rows:
            if parent in descendants and pid not in descendants:
                descendants.add(pid)
                changed = True

    for pid, _, command in rows:
        if pid in descendants and "amp threads list" in command:
            return "amux -> amp threads list"
    return "other"


def stop_process_group(process: subprocess.Popen[str]) -> None:
    try:
        os.killpg(process.pid, signal.SIGKILL)
    except ProcessLookupError:
        return
    process.wait()


def monitor_process_shape(
    root_pid: int, stop: threading.Event, observed: list[str]
) -> None:
    while not stop.is_set():
        shape = process_shape(root_pid)
        if shape == "amux -> amp threads list":
            observed[0] = shape
        stop.wait(0.5)


def run_bounded(
    command: Sequence[str], *, observe_shape: bool = False
) -> tuple[subprocess.Popen[str], str, str, bool]:
    process = subprocess.Popen(
        list(command),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        start_new_session=True,
    )
    monitor_stop = threading.Event()
    observed_shape = ["other"]
    monitor = None
    if observe_shape:
        monitor = threading.Thread(
            target=monitor_process_shape,
            args=(process.pid, monitor_stop, observed_shape),
            daemon=True,
        )
        monitor.start()
    try:
        stdout, stderr = process.communicate(timeout=DEADLINE_SECONDS)
        monitor_stop.set()
        return process, stdout, stderr, False
    except subprocess.TimeoutExpired:
        stop_process_group(process)
        monitor_stop.set()
        if monitor is not None:
            monitor.join(timeout=0.2)
        return process, "", observed_shape[0], True


def worker_doctor(thread: str) -> int:
    process, stdout, stderr_or_shape, timed_out = run_bounded(
        ["amux", "--json", "worker", "doctor", "--thread", thread],
        observe_shape=True,
    )
    if timed_out:
        print(
            json.dumps(
                {
                    "check": "worker-doctor",
                    "status": "timed-out",
                    "thread": thread,
                    "process_shape": stderr_or_shape,
                    "deadline_seconds": DEADLINE_SECONDS,
                },
                sort_keys=True,
            )
        )
        return 124

    result: dict[str, object] = {
        "check": "worker-doctor",
        "thread": thread,
        "deadline_seconds": DEADLINE_SECONDS,
        "exit_code": process.returncode,
        "stdout_bytes": len(stdout.encode()),
        "stderr_bytes": len(stderr_or_shape.encode()),
    }
    try:
        payload = json.loads(stdout)
    except json.JSONDecodeError:
        payload = None

    expected_command = isinstance(payload, dict) and payload.get("command") == "worker doctor"
    expected_schema = isinstance(payload, dict) and payload.get("schema_version") == 1
    result["schema_valid"] = expected_command and expected_schema
    identity_valid = True
    outcome_count = 0
    for key in ("successful", "skipped", "failed"):
        value = payload.get(key) if isinstance(payload, dict) else None
        result[f"{key}_count"] = len(value) if isinstance(value, list) else None
        if not isinstance(value, list):
            identity_valid = False
            continue
        outcome_count += len(value)
        for item in value:
            resource = item.get("resource") if isinstance(item, dict) else None
            if not (
                isinstance(resource, dict)
                and resource.get("kind") == "worker"
                and resource.get("thread") == thread
            ):
                identity_valid = False

    result["identity_valid"] = identity_valid and outcome_count > 0

    result["status"] = (
        "ok"
        if process.returncode == 0
        and result["schema_valid"]
        and result["identity_valid"]
        else "failed"
    )
    print(json.dumps(result, sort_keys=True))
    return process.returncode if process.returncode != 0 else (0 if result["status"] == "ok" else 1)


def amp_list(include_archived: bool) -> int:
    command = ["amp", "threads", "list", "--json", "--limit", "500", "--offset", "0"]
    if include_archived:
        command.append("--include-archived")

    process, stdout, stderr_or_shape, timed_out = run_bounded(command)
    result = {
        "check": "amp-threads-list",
        "include_archived": include_archived,
        "deadline_seconds": DEADLINE_SECONDS,
    }
    if timed_out:
        result["status"] = "timed-out"
        print(json.dumps(result, sort_keys=True))
        return 124

    result["status"] = "ok" if process.returncode == 0 else "failed"
    result["exit_code"] = process.returncode
    result["result_bytes"] = len(stdout.encode())
    result["stderr_bytes"] = len(stderr_or_shape.encode())
    print(json.dumps(result, sort_keys=True))
    return process.returncode


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run bounded diagnostics for checking-bta-dev-health."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    doctor = subparsers.add_parser("worker-doctor")
    doctor.add_argument("--thread", required=True)

    listing = subparsers.add_parser("amp-list")
    listing.add_argument("--include-archived", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.command == "worker-doctor":
        return worker_doctor(args.thread)
    return amp_list(args.include_archived)


if __name__ == "__main__":
    raise SystemExit(main())
