"""Route window, workspace, and screen shortcuts through OmniWM and native focus."""

import argparse
import fcntl
import importlib
import json
import math
import os
import subprocess
import sys
from functools import cached_property
from pathlib import Path


class WindowActionError(Exception):
    """A shortcut could not safely identify or change its target window."""


def omniwm(*arguments):
    """Send a native action or query and preserve command failures."""
    try:
        return subprocess.run(
            ["omniwmctl", *arguments],
            check=True,
            capture_output=True,
            text=True,
            timeout=10,
        ).stdout
    except subprocess.CalledProcessError as error:
        raise WindowActionError(
            (error.stderr or error.stdout or str(error)).strip()
        ) from error


def query_list(kind):
    """Read a complete OmniWM snapshot list for action routing."""
    try:
        response = json.loads(omniwm("query", kind, "--format", "json"))
        if response.get("ok") is not True:
            raise WindowActionError(f"OmniWM rejected the {kind} query")
        snapshots = response["result"]["payload"][kind]
        if not isinstance(snapshots, list) or any(
            not isinstance(w, dict) for w in snapshots
        ):
            raise WindowActionError(f"Invalid OmniWM {kind} list")
        return snapshots
    except (ValueError, KeyError, TypeError, AttributeError) as error:
        raise WindowActionError(f"Invalid OmniWM {kind} response") from error


def visible(window):
    """Exclude parked, hidden, and off-workspace windows."""
    return (
        window.get("isVisible") is True
        and not window.get("isAppHidden")
        and window.get("hiddenReason")
        not in ("scratchpad", "workspace-inactive", "tab-inactive")
    )


def rect(value):
    """Validate native or queried geometry before using it in an action."""
    try:
        result = {key: float(value[key]) for key in ("x", "y", "width", "height")}
    except (KeyError, TypeError, ValueError) as error:
        raise WindowActionError("Invalid window geometry") from error
    if (
        not all(math.isfinite(v) for v in result.values())
        or min(result["width"], result["height"]) <= 0
    ):
        raise WindowActionError("Invalid window dimensions")
    return result


def foreground_window(snapshots, native):
    """Use the foreground app instead of a remembered tiled focus token."""
    pid = native.foreground_pid()
    candidates = [w for w in snapshots if w.get("pid") == pid and visible(w)]
    if not candidates:
        return None
    if len(candidates) == 1:
        return candidates[0]
    identity = native.focused_identity()
    if identity.get("windowId") is not None:
        matches = [w for w in candidates if w.get("windowId") == identity["windowId"]]
        if not matches:
            return None
    else:
        matches = [w for w in candidates if w.get("title") == identity["title"]]
        if len(matches) > 1:
            actual = rect(identity["frame"])
            matches = [
                w
                for w in matches
                if all(abs(rect(w["frame"])[k] - actual[k]) <= 1 for k in actual)
            ]
    if len(matches) != 1:
        raise WindowActionError(
            "Cannot uniquely identify the foreground window; no action sent"
        )
    return matches[0]


def layer_windows(snapshots, current, mode):
    """Find visible peers in one workspace, display, and layout layer."""
    return [
        w
        for w in snapshots
        if visible(w)
        and w.get("mode") == mode
        and w.get("workspace", {}).get("rawName")
        == current.get("workspace", {}).get("rawName")
        and w.get("display", {}).get("id") == current.get("display", {}).get("id")
        and w.get("id") != current["id"]
    ]


def focus_adjacent_workspace(current, direction):
    """Implement reference up/down workspace traversal without resizing tiled windows."""
    workspaces = [
        w
        for w in query_list("workspaces")
        if w.get("display", {}).get("id") == current.get("display", {}).get("id")
    ]
    if any(
        not isinstance(w.get("number"), int) or not isinstance(w.get("rawName"), str)
        for w in workspaces
    ):
        raise WindowActionError("Invalid workspace navigation metadata")
    workspaces.sort(key=lambda w: w["number"])
    index = next(
        (
            i
            for i, w in enumerate(workspaces)
            if w["rawName"] == current.get("workspace", {}).get("rawName")
        ),
        None,
    )
    if index is None:
        return
    index += -1 if direction == "up" else 1
    if 0 <= index < len(workspaces):
        omniwm("workspace", "focus-name", workspaces[index]["rawName"])


def next_display(displays, source_id):
    """Cycle through connected screens in OmniWM's display query order."""
    identities = [display.get("id") for display in displays]
    if (
        any(not isinstance(identity, str) or not identity for identity in identities)
        or len(set(identities)) != len(identities)
        or source_id not in identities
    ):
        raise WindowActionError("Cannot identify the source and destination screens")
    return displays[(identities.index(source_id) + 1) % len(displays)]


def send_window(current, workspace, *, follow=False, display_id=None):
    """Send one ordinary window and explicitly select the source or destination afterward."""
    matches = [w for w in query_list("workspaces") if w.get("rawName") == workspace]
    if len(matches) != 1:
        raise WindowActionError(
            f"Workspace {workspace!r} must identify one configured workspace"
        )
    if display_id is not None and matches[0].get("display", {}).get("id") != display_id:
        raise WindowActionError("The destination workspace is no longer on that screen")
    source = current.get("workspace", {}).get("rawName")
    if not isinstance(source, str) or not source:
        raise WindowActionError("Cannot identify the source workspace")
    if source == workspace:
        return
    if current.get("isScratchpad"):
        raise WindowActionError(
            "Summon the scratchpad on the destination screen instead of sending it"
        )
    if current.get("isFullscreen"):
        raise WindowActionError("Exit fullscreen before sending a window")
    identity = current.get("id")
    if not isinstance(identity, str) or not identity:
        raise WindowActionError("Cannot identify the window to send")
    omniwm("window", "navigate", identity)
    omniwm("window", "move-to-workspace", identity, workspace)
    moved = [w for w in query_list("windows") if w.get("id") == identity]
    if len(moved) != 1 or moved[0].get("workspace", {}).get("rawName") != workspace:
        raise WindowActionError(f"Window did not reach workspace {workspace!r}")
    if follow:
        omniwm("window", "focus", identity)
    else:
        try:
            omniwm("workspace", "focus-name", source)
        except WindowActionError:
            # An already-current workspace reports no_change through a nonzero exit.
            if not any(
                w.get("rawName") == source and w.get("isCurrent") is True
                for w in query_list("workspaces")
            ):
                raise


# Floating windows step by this fraction of the relevant usable screen axis.
# Niri's reference step is 50 logical pixels, which matches 5% on a 1000-wide
# screen.
MOVE_STEP_FRACTION = 0.05


# Floated windows keep this distance to the screen edges so an edgeless
# window (Alacritty) never looks like it extends past the screen. Matches
# OmniWM's focus border width; keep in sync with omniwm-settings.nix.
SCREEN_INSET = 5.0

# The Mission Control "move one space" shortcut as recorded in System
# Settings (shift + ctrl + option on the arrow keys), plus the phantom fn
# flag macOS adds to real arrow events. Synthetic events need both to match
# the hotkey, and must come from a HID-system event source.
SPACE_HOTKEY_FLAGS = 0x8E0000
SPACE_ARROW_KEYCODES = {"left": 123, "right": 124}


def change_space(direction):
    """Synthesize the recorded Mission Control shortcut for native Spaces."""
    cg = importlib.import_module("Quartz")
    source = cg.CGEventSourceCreate(cg.kCGEventSourceStateHIDSystemState)
    keycode = SPACE_ARROW_KEYCODES[direction]
    for pressed in (True, False):
        event = cg.CGEventCreateKeyboardEvent(source, keycode, pressed)
        cg.CGEventSetFlags(event, SPACE_HOTKEY_FLAGS)
        cg.CGEventPost(cg.kCGHIDEventTap, event)


def align_window_edge(area, frame, edge):
    """Move a float so its leading edge sits at the inset screen border."""
    horizontal = edge in ("left", "right")
    axis, dimension = ("x", "width") if horizontal else ("y", "height")
    low = area[axis] + SCREEN_INSET
    high = area[axis] + area[dimension] - SCREEN_INSET
    if edge in ("right", "down"):
        frame[axis] = high - frame[dimension]
    else:
        frame[axis] = low
    keep_onscreen(area, frame)


def keep_onscreen(area, frame):
    """Clamp a floating frame inside the usable screen, inset by the border."""
    frame["x"] = max(
        area["x"] + SCREEN_INSET,
        min(frame["x"], area["x"] + area["width"] - frame["width"] - SCREEN_INSET),
    )
    frame["y"] = max(
        area["y"] + SCREEN_INSET,
        min(frame["y"], area["y"] + area["height"] - frame["height"] - SCREEN_INSET),
    )


def parse(arguments):
    """Validate the private shortcut command line."""
    parser = argparse.ArgumentParser(description=__doc__)
    actions = parser.add_subparsers(dest="action", required=True)
    actions.add_parser("focus").add_argument(
        "direction", choices=("left", "right", "up", "down")
    )
    actions.add_parser("move").add_argument(
        "direction", choices=("left", "right", "up", "down")
    )
    actions.add_parser("move-max").add_argument(
        "direction", choices=("left", "right", "up", "down")
    )
    actions.add_parser("send-workspace").add_argument("workspace")
    actions.add_parser("send-monitor")
    actions.add_parser("focus-monitor")
    actions.add_parser("space").add_argument("direction", choices=("left", "right"))
    actions.add_parser("cycle-tabs").add_argument(
        "direction", choices=("forward", "backward")
    )
    resize = actions.add_parser("resize")
    resize.add_argument("axis", choices=("horizontal", "vertical"))
    resize.add_argument("change", choices=("grow", "shrink"))
    for name in (
        "center",
        "maximize",
        "cycle-width",
        "switch-layer",
        "merge",
        "split",
        "toggle-tabs",
    ):
        actions.add_parser(name)
    return parser.parse_args(arguments)


def perform(arguments, native, *, step=10, presets=(0.5, 0.75, 0.9)):
    """Apply niri-like keyboard semantics without changing an unfocused layer."""
    action = parse(arguments)
    if action.action == "space":
        change_space(action.direction)
        return
    displays = None
    if action.action in ("focus-monitor", "send-monitor"):
        displays = query_list("displays")
        if len(displays) < 2:
            return
        if action.action == "focus-monitor":
            omniwm("command", "focus-monitor", "next")
            return
    snapshots = query_list("windows")
    current = foreground_window(snapshots, native)
    if current is None:
        return
    mode = current.get("mode")
    if mode not in ("floating", "tiling"):
        raise WindowActionError("Unknown foreground window mode")
    if action.action == "send-workspace":
        send_window(current, action.workspace)
        return
    if action.action == "send-monitor":
        target = next_display(displays, current.get("display", {}).get("id"))
        workspace = target.get("activeWorkspace")
        if (
            not isinstance(workspace, dict)
            or not isinstance(workspace.get("rawName"), str)
            or not workspace["rawName"]
        ):
            raise WindowActionError("The destination screen has no active workspace")
        send_window(current, workspace["rawName"], follow=True, display_id=target["id"])
        return
    if action.action == "switch-layer":
        if mode == "floating":
            omniwm("window", "focus", current["id"])
            omniwm("command", "toggle-floating-focus")
        else:
            peers = layer_windows(snapshots, current, "floating")
            order = {
                identity: rank for rank, identity in enumerate(native.stacking_order())
            }
            if peers:
                target = min(
                    peers, key=lambda w: order.get(w.get("windowId"), len(order))
                )
                omniwm("window", "focus", target["id"])
        return
    if mode == "tiling":
        # The focus flag can disagree with Niri's selected node after app/window changes.
        omniwm("window", "navigate", current["id"])
        if action.action == "focus":
            command = (
                [f"focus-window-or-workspace-{action.direction}"]
                if action.direction in ("up", "down")
                else ["focus", action.direction]
            )
        elif action.action == "resize":
            command = [
                "set-container-primary-span"
                if action.axis == "horizontal"
                else "set-window-secondary-span",
                f"{'+' if action.change == 'grow' else '-'}{step:g}%",
            ]
        elif action.action == "move":
            command = ["move-column", action.direction]
        elif action.action == "move-max":
            command = {
                "left": ["move-column-to-first"],
                "right": ["move-column-to-last"],
                "up": ["move-column", "up"],
                "down": ["move-column", "down"],
            }[action.direction]
        elif action.action == "cycle-tabs":
            command = [
                "focus-window",
                "down-or-top" if action.direction == "forward" else "up-or-bottom",
            ]
        else:
            command = {
                "center": ["center-column"],
                "maximize": ["toggle-container-full-primary-span"],
                "cycle-width": ["cycle-size", "forward"],
                "merge": ["consume-window-into-column"],
                "split": ["expel-window-from-column"],
                "toggle-tabs": ["toggle-column-tabbed"],
            }[action.action]
        omniwm("command", *command)
        return
    if action.action == "focus":
        axis = "x" if action.direction in ("left", "right") else "y"
        dimension = "width" if axis == "x" else "height"
        sign = -1 if action.direction in ("left", "up") else 1
        origin = rect(current["frame"])
        center = origin[axis] + origin[dimension] / 2
        order = {
            identity: rank for rank, identity in enumerate(native.stacking_order())
        }
        candidates = []
        for peer in layer_windows(snapshots, current, "floating"):
            frame = rect(peer["frame"])
            distance = sign * (frame[axis] + frame[dimension] / 2 - center)
            if distance > 0:
                candidates.append(
                    (distance, order.get(peer.get("windowId"), len(order)), peer["id"])
                )
        if candidates:
            omniwm("window", "focus", min(candidates)[2])
        elif action.direction in ("up", "down"):
            focus_adjacent_workspace(current, action.direction)
        return
    # Column-only actions leave floating windows unchanged, matching niri.
    if action.action in ("maximize", "merge", "split", "toggle-tabs", "cycle-tabs"):
        return
    if current.get("isFullscreen"):
        raise WindowActionError("Exit fullscreen before changing floating geometry")
    frame = rect(native.read_frame(current))
    area = rect(native.working_area(current))
    if action.action == "resize":
        dimension = "width" if action.axis == "horizontal" else "height"
        frame[dimension] = max(
            1,
            frame[dimension]
            + area[dimension] * step / 100 * (1 if action.change == "grow" else -1),
        )
        keep_onscreen(area, frame)
    elif action.action == "cycle-width":
        widths = [area["width"] * preset for preset in presets]
        frame["width"] = next(
            (width for width in widths if width > frame["width"] + 1), widths[0]
        )
        keep_onscreen(area, frame)
    elif action.action == "move":
        if action.direction in ("left", "right"):
            frame["x"] += (
                MOVE_STEP_FRACTION
                * area["width"]
                * (-1 if action.direction == "left" else 1)
            )
        else:
            frame["y"] += (
                MOVE_STEP_FRACTION
                * area["height"]
                * (-1 if action.direction == "up" else 1)
            )
        keep_onscreen(area, frame)
    elif action.action == "move-max":
        align_window_edge(area, frame, action.direction)
    elif action.action == "center":
        frame["x"] = area["x"] + max(0, (area["width"] - frame["width"]) / 2)
        frame["y"] = area["y"] + max(0, (area["height"] - frame["height"]) / 2)
    native.write_frame(current, frame)


class Accessibility:
    """Use public macOS APIs to resize the actual keyboard-focused window."""

    def __init__(self):
        self.appkit = importlib.import_module("AppKit")
        self.cf = importlib.import_module("CoreFoundation")
        self.target = None

    @cached_property
    def ax(self):
        """Load AX bindings when window identity or geometry needs them."""
        return importlib.import_module("ApplicationServices")

    @cached_property
    def quartz(self):
        """Load window-list bindings when floating focus needs stacking order."""
        return importlib.import_module("Quartz")

    def foreground_pid(self):
        """Read the application receiving keyboard input."""
        # AppKit caches this property until foreground-change notifications are processed.
        self.cf.CFRunLoopRunInMode(self.cf.kCFRunLoopDefaultMode, 0.01, False)
        application = self.appkit.NSWorkspace.sharedWorkspace().frontmostApplication()
        return application.processIdentifier() if application is not None else None

    def attribute(self, element, name):
        """Read an Accessibility attribute or report its native error code."""
        error, value = self.ax.AXUIElementCopyAttributeValue(element, name, None)
        if error or value is None:
            raise WindowActionError(f"Cannot read Accessibility {name} ({error})")
        return value

    def focused_element(self, pid):
        """Resolve one focused AX window while checking application ownership."""
        if not self.ax.AXIsProcessTrusted():
            raise WindowActionError(
                "Allow Accessibility for the shortcut launcher (normally skhd)"
            )
        if self.foreground_pid() != pid:
            raise WindowActionError("Focus changed; no geometry action sent")
        application = self.ax.AXUIElementCreateApplication(pid)
        return self.attribute(application, self.ax.kAXFocusedWindowAttribute)

    def geometry(self, element):
        """Read native position and size in top-left screen coordinates."""
        _, position = self.ax.AXValueGetValue(
            self.attribute(element, self.ax.kAXPositionAttribute),
            self.ax.kAXValueCGPointType,
            None,
        )
        _, size = self.ax.AXValueGetValue(
            self.attribute(element, self.ax.kAXSizeAttribute),
            self.ax.kAXValueCGSizeType,
            None,
        )
        if position is None or size is None:
            raise WindowActionError("Cannot decode Accessibility window geometry")
        return rect(
            {
                "x": position.x,
                "y": position.y,
                "width": size.width,
                "height": size.height,
            }
        )

    def window_id(self, pid, frame):
        """Find a unique WindowServer window matching the application's native bounds."""
        entries = self.quartz.CGWindowListCopyWindowInfo(
            self.quartz.kCGWindowListOptionAll, self.quartz.kCGNullWindowID
        )
        coordinates = (("x", "X"), ("y", "Y"), ("width", "Width"), ("height", "Height"))
        matches = set()
        for entry in entries or ():
            if entry.get(self.quartz.kCGWindowOwnerPID) != pid:
                continue
            bounds = entry.get(self.quartz.kCGWindowBounds) or {}
            if all(
                abs(float(bounds.get(key, math.inf)) - frame[axis]) <= 1
                for axis, key in coordinates
            ):
                matches.add(int(entry[self.quartz.kCGWindowNumber]))
        return next(iter(matches)) if len(matches) == 1 else None

    def focused_identity(self):
        """Identify native keyboard focus independently of cached window titles."""
        pid = self.foreground_pid()
        element = self.focused_element(pid)
        frame = self.geometry(element)
        identity = self.window_id(pid, frame)
        if identity is not None:
            return {"windowId": identity, "frame": frame}
        return {
            "title": str(self.attribute(element, self.ax.kAXTitleAttribute)),
            "frame": frame,
        }

    def read_frame(self, target):
        """Capture the native focused element before a geometry operation."""
        element = self.focused_element(target["pid"])
        frame = self.geometry(element)
        identity = self.window_id(target["pid"], frame)
        if identity is not None:
            matches = identity == target.get("windowId")
        else:
            matches = str(
                self.attribute(element, self.ax.kAXTitleAttribute)
            ) == target.get("title")
        if not matches:
            raise WindowActionError("Window focus changed; no geometry action sent")
        self.target = (target["pid"], element)
        return frame

    def working_area(self, target):
        """Convert the target display's usable AppKit bounds to Accessibility coordinates."""
        screens = self.appkit.NSScreen.screens()
        identifier = target.get("display", {}).get("id", "")
        screen = next(
            (
                s
                for s in screens
                if identifier
                == f"display:{int(s.deviceDescription()['NSScreenNumber'])}"
            ),
            None,
        )
        if screen is None or not screens:
            raise WindowActionError("Cannot identify the focused window's display")
        area = screen.visibleFrame()
        primary_height = screens[0].frame().size.height
        return rect(
            {
                "x": area.origin.x,
                "y": primary_height - area.origin.y - area.size.height,
                "width": area.size.width,
                "height": area.size.height,
            }
        )

    def write_frame(self, target, frame):
        """Validate focus again and apply size and position to the captured AX element."""
        pid, element = self.target
        current = self.focused_element(pid)
        if not self.cf.CFEqual(element, current):
            raise WindowActionError("Window focus changed; no geometry action sent")
        previous = self.geometry(element)
        if previous["width"] != frame["width"] or previous["height"] != frame["height"]:
            area = self.working_area(target)
            # AX sizing clips at screen edges; temporarily make room before resizing.
            x = max(
                area["x"],
                min(previous["x"], area["x"] + area["width"] - frame["width"]),
            )
            y = max(
                area["y"],
                min(previous["y"], area["y"] + area["height"] - frame["height"]),
            )
            if x != previous["x"] or y != previous["y"]:
                self._set_position(element, x, y)
            try:
                size = self.ax.AXValueCreate(
                    self.ax.kAXValueCGSizeType, (frame["width"], frame["height"])
                )
                error = self.ax.AXUIElementSetAttributeValue(
                    element, self.ax.kAXSizeAttribute, size
                )
                if error:
                    raise WindowActionError(f"Cannot resize focused window ({error})")
            finally:
                self._set_position(element, frame["x"], frame["y"])
        elif previous["x"] != frame["x"] or previous["y"] != frame["y"]:
            self._set_position(element, frame["x"], frame["y"])

    def _set_position(self, element, x, y):
        """Set a captured AX element's position and report native failures."""
        position = self.ax.AXValueCreate(self.ax.kAXValueCGPointType, (x, y))
        error = self.ax.AXUIElementSetAttributeValue(
            element, self.ax.kAXPositionAttribute, position
        )
        if error:
            raise WindowActionError(f"Cannot position focused window ({error})")

    def stacking_order(self):
        """Return visible native window IDs in front-to-back order."""
        info = self.quartz.CGWindowListCopyWindowInfo(
            self.quartz.kCGWindowListOptionOnScreenOnly, self.quartz.kCGNullWindowID
        )
        return [int(window[self.quartz.kCGWindowNumber]) for window in info or []]


def main(argv=None):
    """Serialize shortcuts and report unsupported or unsafe operations."""
    try:
        step = float(os.environ.get("OMNIWM_RESIZE_STEP", "10"))
        presets = json.loads(os.environ.get("OMNIWM_WIDTH_PRESETS", "[0.5,0.75,0.9]"))
        if (
            not math.isfinite(step)
            or step <= 0
            or not isinstance(presets, list)
            or not presets
            or any(not 0 < float(p) <= 1 for p in presets)
        ):
            raise WindowActionError("Invalid resize configuration")
        cache = Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache")
        if not cache.is_absolute():
            cache = Path.home() / ".cache"
        cache /= "omniwm"
        cache.mkdir(mode=0o700, parents=True, exist_ok=True)
        with (cache / "window.lock").open("a") as lock:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                return 0
            perform(
                sys.argv[1:] if argv is None else argv,
                Accessibility(),
                step=step,
                presets=[float(p) for p in presets],
            )
    except (
        WindowActionError,
        OSError,
        ValueError,
        TypeError,
        subprocess.SubprocessError,
    ) as error:
        print(f"omniwm-window: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
