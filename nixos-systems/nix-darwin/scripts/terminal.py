"""Manage terminal roles and application focus for the work Mac."""

import argparse
import fcntl
import json
import os
import subprocess
import sys
import time
from pathlib import Path


class TerminalError(Exception):
    """A terminal action could not be completed safely."""


def omniwm(*arguments):
    """Run an IPC command and report transport or action failures."""
    try:
        result = subprocess.run(
            ["omniwmctl", *arguments],
            check=True,
            capture_output=True,
            text=True,
            timeout=10,
        )
    except subprocess.CalledProcessError as error:
        details = (error.stderr or error.stdout or str(error)).strip()
        raise TerminalError(details) from error
    return result.stdout


def query(kind):
    """Read a successful structured IPC payload."""
    try:
        response = json.loads(omniwm("query", kind, "--format", "json"))
        if response.get("ok") is not True:
            raise TerminalError(f"OmniWM rejected the {kind} query")
        payload = response["result"]["payload"]
        if not isinstance(payload, dict):
            raise TerminalError(f"Invalid OmniWM {kind} payload")
        return payload
    except (ValueError, KeyError, TypeError, AttributeError) as error:
        raise TerminalError(f"Invalid OmniWM {kind} response") from error


def windows():
    """Read window snapshots without filtering parked or off-workspace windows."""
    result = query("windows").get("windows")
    if not isinstance(result, list) or any(not isinstance(w, dict) for w in result):
        raise TerminalError("Invalid OmniWM window list")
    return result


def active_workspace():
    """Read the invocation workspace before a workspace-sensitive scratchpad action."""
    active = query("active-workspace").get("workspace")
    if (
        not isinstance(active, dict)
        or not isinstance(active.get("rawName"), str)
        or not active["rawName"]
    ):
        raise TerminalError("No active OmniWM workspace")
    return active["rawName"]


def find_terminal(snapshots, title):
    """Find one owned window by exact bundle ID and fixed title."""
    matches = [
        w
        for w in snapshots
        if w.get("app", {}).get("bundleId") == "org.alacritty"
        and w.get("title") == title
    ]
    if len(matches) > 1:
        raise TerminalError(
            f"Multiple {title} windows; close the duplicate before retrying"
        )
    if not matches:
        return None
    if not isinstance(matches[0].get("id"), str) or not matches[0]["id"]:
        raise TerminalError(f"Invalid window ID for {title}")
    return matches[0]


def check_overlay_slot(snapshots, target):
    """Refuse to take over a slot containing another window."""
    for item in snapshots:
        if (
            item.get("isScratchpad")
            and item.get("scratchpadIndex") == 1
            and (target is None or item.get("id") != target["id"])
        ):
            raise TerminalError(
                "Scratchpad 1 contains another window; leave it empty for the overlay"
            )
    if target and target.get("isScratchpad") and target.get("scratchpadIndex") != 1:
        raise TerminalError(
            "The overlay belongs to another scratchpad; unassign it before retrying"
        )


def spawn_terminal(role, directory, logs):
    """Start a client with a fixed title and atomically attach or create its session."""
    title = f"code/{role}"
    executable = os.environ.get("OMNIWM_ALACRITTY")
    if not executable:
        raise TerminalError("Alacritty's macOS bundle executable is not configured")
    arguments = [
        executable,
        "--title",
        title,
        "--option",
        "window.dynamic_title=false",
        "--working-directory",
        str(directory),
    ]
    if role == "overlay":
        arguments.extend(
            [
                "--option",
                "window.dimensions.columns=90",
                "--option",
                "window.dimensions.lines=22",
            ]
        )
    arguments.extend(
        ["--command", "tmux", "new-session", "-A", "-s", title, "-c", str(directory)]
    )
    environment = os.environ.copy()
    environment.pop("TMUX", None)
    environment.pop("TMUX_PANE", None)
    with (logs / f"terminal-{role}.log").open("ab") as log:
        subprocess.Popen(
            arguments,
            stdin=subprocess.DEVNULL,
            stdout=log,
            stderr=subprocess.STDOUT,
            env=environment,
            start_new_session=True,
        )


def park_overlay(unless_window=None):
    """Park the owned revealed overlay on the invocation workspace unless it is selected."""
    snapshots = windows()
    target = find_terminal(snapshots, "code/overlay")
    if (
        target is None
        or target["id"] == unless_window
        or not target.get("isScratchpad")
        or target.get("scratchpadIndex") != 1
        or not target.get("isVisible")
        or target.get("hiddenReason") == "scratchpad"
        or target.get("isAppHidden")
        or target.get("isFullscreen")
    ):
        return
    # A toggle on another workspace would summon the overlay instead of parking it.
    if (target.get("workspace") or {}).get("rawName") != active_workspace():
        return
    check_overlay_slot(snapshots, target)
    omniwm("command", "scratchpad", "toggle", "1")
    for _ in range(50):
        current = find_terminal(windows(), "code/overlay")
        if (
            current is None
            or not current.get("isVisible")
            or current.get("isAppHidden")
            or current.get("hiddenReason") == "scratchpad"
        ):
            return
        time.sleep(0.05)
    raise TerminalError("Overlay did not park; application activation cancelled")


def activate_terminal(role, directory, logs):
    """Spawn or focus a main terminal, or show/focus/hide the overlay."""
    if role not in ("main", "overlay"):
        raise TerminalError(f"Unknown terminal role: {role}")
    if role == "main":
        park_overlay()
    title = f"code/{role}"
    snapshots = windows()
    target = find_terminal(snapshots, title)
    if role == "overlay":
        check_overlay_slot(snapshots, target)
    elif target and target.get("isFocused") and not target.get("isAppHidden"):
        return

    workspace = active_workspace()

    if target is None:
        if not directory.is_dir():
            raise TerminalError(f"Working directory does not exist: {directory}")
        spawn_terminal(role, directory, logs)
        for _ in range(50):
            snapshots = windows()
            target = find_terminal(snapshots, title)
            if target is not None:
                break
            time.sleep(0.1)
        else:
            raise TerminalError(
                f"OmniWM did not discover {title}; see {logs / f'terminal-{role}.log'}"
            )

    identity = target["id"]
    if target.get("isAppHidden"):
        # Explicit focus can unhide an app and reveal its scratchpad; navigate cannot.
        omniwm("window", "focus", identity)
        for _ in range(50):
            restored = find_terminal(windows(), title)
            if (
                restored is not None
                and not restored.get("isAppHidden")
                and restored.get("isVisible")
                and restored.get("isFocused")
            ):
                target = restored
                identity = target["id"]
                break
            time.sleep(0.05)
        else:
            raise TerminalError(
                f"OmniWM did not restore {title}; no additional client was created"
            )
        if role == "overlay" and target.get("isScratchpad"):
            return

    if role == "main":
        moved = target.get("workspace", {}).get("rawName") != workspace
        if moved:
            omniwm("window", "move-to-workspace", identity, workspace)
        if moved or not target.get("isFocused"):
            omniwm("window", "navigate", identity)
        return

    check_overlay_slot(snapshots, target)
    if target.get("isFullscreen"):
        raise TerminalError("Exit fullscreen before toggling the overlay")

    if not target.get("isScratchpad"):
        if target.get("workspace", {}).get("rawName") != workspace:
            omniwm("window", "move-to-workspace", identity, workspace)
        if not target.get("isFocused"):
            omniwm("window", "navigate", identity)
        # Stable 0.7.6 assigns the focused window, so confirm ownership before assigning.
        for _ in range(10):
            snapshots = windows()
            focused = next(
                (
                    w
                    for w in snapshots
                    if w.get("id") == identity and w.get("isFocused")
                ),
                None,
            )
            if focused is not None:
                break
            time.sleep(0.05)
        else:
            raise TerminalError(
                "Overlay did not obtain focus; scratchpad assignment cancelled"
            )
        check_overlay_slot(snapshots, focused)
        omniwm("command", "scratchpad", "assign", "1")
        target = find_terminal(windows(), title)
        if (
            target is None
            or not target.get("isScratchpad")
            or target.get("scratchpadIndex") != 1
        ):
            raise TerminalError("Overlay scratchpad assignment did not take effect")
        if target.get("hiddenReason") == "scratchpad" or not target.get("isVisible"):
            omniwm("command", "scratchpad", "toggle", "1")
        elif not target.get("isFocused"):
            omniwm("window", "navigate", identity)
        return

    if (
        target.get("hiddenReason") == "scratchpad"
        or not target.get("isVisible")
        or target.get("workspace", {}).get("rawName") != workspace
        or target.get("isFocused")
    ):
        omniwm("command", "scratchpad", "toggle", "1")
    else:
        omniwm("window", "navigate", identity)


def main(argv=None):
    """Serialize overlay dismissal with terminal and application activation."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("role", choices=("main", "overlay", "focus-app"))
    destination = parser.add_mutually_exclusive_group()
    destination.add_argument("--window", help="Managed application window to focus")
    destination.add_argument(
        "--bundle-id", help="Application to activate when no managed window exists"
    )
    parser.add_argument(
        "--directory", type=Path, default=Path.home() / "projects/coralogix"
    )
    arguments = parser.parse_args(argv)
    if (arguments.role == "focus-app") != bool(arguments.window or arguments.bundle_id):
        parser.error(
            "focus-app requires --window or --bundle-id; terminal roles accept neither"
        )
    cache_home = Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache")
    if not cache_home.is_absolute():
        cache_home = Path.home() / ".cache"
    cache = cache_home / "omniwm"
    try:
        cache.mkdir(mode=0o700, parents=True, exist_ok=True)
        with (cache / "terminal.lock").open("a") as lock:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                if arguments.role == "focus-app":
                    raise TerminalError(
                        "Terminal action in progress; application switch cancelled"
                    ) from None
                return 0
            if arguments.role == "focus-app":
                park_overlay(unless_window=arguments.window)
                if arguments.window:
                    omniwm("window", "navigate", arguments.window)
                else:
                    subprocess.run(
                        ["open", "-b", arguments.bundle_id], check=True, timeout=10
                    )
            else:
                activate_terminal(arguments.role, arguments.directory, cache)
    except (TerminalError, OSError, subprocess.SubprocessError) as error:
        print(f"omniwm-terminal: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
