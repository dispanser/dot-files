"""Test focus-aware layout actions without moving desktop windows."""

import importlib.util
import json
import sys
import unittest
from pathlib import Path
from unittest import mock

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/window-action.py"
spec = importlib.util.spec_from_file_location("omniwm_window", SCRIPT)
window_action = importlib.util.module_from_spec(spec)


def window(identity="float", *, mode="floating", pid=10, **overrides):
    """Build a visible managed window snapshot."""
    return {
        "id": identity,
        "windowId": pid,
        "pid": pid,
        "title": identity,
        "mode": mode,
        "isFocused": True,
        "isVisible": True,
        "workspace": {"rawName": "1"},
        "display": {"id": "display:1"},
        "frame": {"x": 100.0, "y": 100.0, "width": 400.0, "height": 300.0},
        **overrides,
    }


class Accessibility:
    """Record geometry changes and provide the real foreground application."""

    def __init__(self, pid=10):
        self.pid = pid
        self.frame = {"x": 100.0, "y": 100.0, "width": 400.0, "height": 300.0}
        self.area = {"x": 0.0, "y": 20.0, "width": 1000.0, "height": 800.0}
        self.changes = []
        self.order = []
        self.title = "float"
        self.window_id = None

    def foreground_pid(self):
        """Return the application receiving keyboard input."""
        return self.pid

    def focused_identity(self):
        """Provide native identity when one app owns several windows."""
        return {
            "title": self.title,
            "frame": self.frame.copy(),
            "windowId": self.window_id,
        }

    def read_frame(self, target):
        """Read the focused window's current geometry."""
        return self.frame.copy()

    def working_area(self, target):
        """Return usable display bounds in Accessibility coordinates."""
        return self.area.copy()

    def write_frame(self, target, frame):
        """Record the exact window and new geometry."""
        self.changes.append((target["id"], frame.copy()))
        self.frame = frame.copy()

    def stacking_order(self):
        """Return front-to-back native window IDs."""
        return self.order


class WindowActionTests(unittest.TestCase):
    """Protect floating-layer isolation and reference key semantics."""

    @classmethod
    def setUpClass(cls):
        """Import policy without loading macOS frameworks."""
        spec.loader.exec_module(window_action)

    def setUp(self):
        """Start with an overlay above a remembered tiled window."""
        self.native = Accessibility()
        self.windows = [
            window("tile", mode="tiling", pid=20),
            window(isFocused=False, isScratchpad=True),
        ]
        self.commands = []
        self.workspaces = [
            {"rawName": "1", "number": 1, "display": {"id": "display:1"}}
        ]
        self.displays = [
            {"id": "display:1", "isCurrent": True, "activeWorkspace": {"rawName": "1"}}
        ]

    def cli(self, *arguments):
        """Return query state and record actions without executing them."""
        if arguments[0] == "query":
            kind = arguments[1]
            payload = {
                "windows": self.windows,
                "workspaces": self.workspaces,
                "displays": self.displays,
            }[kind]
            return json.dumps({"ok": True, "result": {"payload": {kind: payload}}})
        self.commands.append(arguments)
        if arguments[:2] == ("window", "move-to-workspace"):
            target = next(w for w in self.windows if w["id"] == arguments[2])
            workspace = next(w for w in self.workspaces if w["rawName"] == arguments[3])
            target["workspace"] = {"rawName": workspace["rawName"]}
            target["display"] = workspace["display"].copy()
        return "executed"

    def act(self, *arguments):
        """Run one action with a mocked WM and Accessibility implementation."""
        with mock.patch.object(window_action, "omniwm", side_effect=self.cli):
            window_action.perform(
                list(arguments), self.native, step=10, presets=[0.5, 0.75, 0.9]
            )

    def two_displays(self):
        """Expose another connected screen with workspace 2 active."""
        self.displays.append(
            {"id": "display:2", "isCurrent": False, "activeWorkspace": {"rawName": "2"}}
        )
        self.workspaces.append(
            {"rawName": "2", "number": 2, "display": {"id": "display:2"}}
        )

    def test_send_workspace_moves_one_window_and_stays_on_source(self):
        """Tiled and ordinary floating windows use explicit IDs and retain the source workspace."""
        self.two_displays()
        for mode in ("tiling", "floating"):
            with self.subTest(mode=mode):
                self.commands.clear()
                self.windows = [window("current", mode=mode)]
                self.act("send-workspace", "2")
                self.assertEqual(
                    self.commands,
                    [
                        ("window", "navigate", "current"),
                        ("window", "move-to-workspace", "current", "2"),
                        ("workspace", "focus-name", "1"),
                    ],
                )
                self.assertEqual(self.windows[0]["workspace"]["rawName"], "2")
                self.assertEqual(self.native.changes, [])

    def test_send_workspace_supports_an_inactive_workspace_on_the_same_screen(self):
        """Workspace sends remain available with one connected screen."""
        self.workspaces.append(
            {"rawName": "2", "number": 2, "display": {"id": "display:1"}}
        )
        self.windows = [window("current", mode="tiling")]
        self.act("send-workspace", "2")
        self.assertEqual(
            self.commands[-2:],
            [
                ("window", "move-to-workspace", "current", "2"),
                ("workspace", "focus-name", "1"),
            ],
        )

    def test_send_uses_native_identity_for_same_process_windows(self):
        """A stale title and tiled focus flag cannot redirect a workspace send."""
        self.two_displays()
        self.windows = [
            window("main", mode="tiling", windowId=1),
            window(
                "new", mode="tiling", windowId=2, title="Alacritty", isFocused=False
            ),
        ]
        self.native.window_id = 2
        self.act("send-workspace", "2")
        self.assertEqual(self.commands[1], ("window", "move-to-workspace", "new", "2"))
        self.assertEqual(self.windows[0]["workspace"]["rawName"], "1")

    def test_send_to_current_workspace_is_a_noop(self):
        """A redundant workspace send leaves focus and geometry unchanged."""
        self.act("send-workspace", "1")
        self.assertEqual(self.commands, [])
        self.assertEqual(self.native.changes, [])

    def test_unknown_or_duplicate_workspace_is_rejected_before_navigation(self):
        """Workspace IDs must identify exactly one configured destination."""
        self.windows = [window("current")]
        for workspaces in ([], [self.workspaces[0], self.workspaces[0]]):
            with self.subTest(workspaces=workspaces):
                self.workspaces = workspaces
                with self.assertRaises(window_action.WindowActionError):
                    self.act("send-workspace", "1")
                self.assertEqual(self.commands, [])

    def test_monitor_keys_are_noops_with_one_screen(self):
        """An inactive second workspace cannot stand in for a second connected screen."""
        self.workspaces.append(
            {"rawName": "2", "number": 2, "display": {"id": "display:1"}}
        )
        for action in ("focus-monitor", "send-monitor"):
            with self.subTest(action=action):
                self.act(action)
                self.assertEqual(self.commands, [])
                self.assertEqual(self.native.changes, [])

    def test_monitor_focus_uses_native_interaction_state(self):
        """Native screen cycling remains usable when the destination has no windows."""
        self.two_displays()
        with mock.patch.object(
            self.native,
            "foreground_pid",
            side_effect=AssertionError("Window focus is not needed"),
        ):
            self.act("focus-monitor")
        self.assertEqual(self.commands, [("command", "focus-monitor", "next")])

    def test_monitor_focus_works_from_an_unmanaged_application(self):
        """Global screen focus remains available without a managed foreground window."""
        self.two_displays()
        self.native.pid = 999
        self.act("focus-monitor")
        self.assertEqual(self.commands, [("command", "focus-monitor", "next")])

    def test_monitor_focus_can_leave_fullscreen_without_navigating_its_window(self):
        """Screen focus delegates fullscreen handling to the native monitor action."""
        self.two_displays()
        self.windows = [window("fullscreen", isFullscreen=True)]
        self.act("focus-monitor")
        self.assertEqual(self.commands, [("command", "focus-monitor", "next")])

    def test_send_monitor_uses_its_visible_workspace_and_follows(self):
        """A screen send targets its active workspace and follows the same window."""
        self.two_displays()
        self.workspaces.append(
            {"rawName": "7", "number": 7, "display": {"id": "display:2"}}
        )
        self.displays[1]["activeWorkspace"] = {"rawName": "7"}
        for mode in ("tiling", "floating"):
            with self.subTest(mode=mode):
                self.commands.clear()
                self.windows = [window("current", mode=mode)]
                self.act("send-monitor")
                self.assertEqual(
                    self.commands,
                    [
                        ("window", "navigate", "current"),
                        ("window", "move-to-workspace", "current", "7"),
                        ("window", "focus", "current"),
                    ],
                )
                self.assertEqual(self.native.changes, [])

    def test_send_monitor_wraps_in_the_native_display_query_order(self):
        """Screen cycling wraps from the last connected display to the first."""
        self.two_displays()
        self.displays.append({"id": "display:3", "activeWorkspace": {"rawName": "3"}})
        self.workspaces.append(
            {"rawName": "3", "number": 3, "display": {"id": "display:3"}}
        )
        self.windows = [
            window("current", workspace={"rawName": "3"}, display={"id": "display:3"})
        ]
        self.act("send-monitor")
        self.assertEqual(
            self.commands[1], ("window", "move-to-workspace", "current", "1")
        )

    def test_invalid_monitor_destinations_are_rejected_before_navigation(self):
        """Missing source screens, duplicate IDs, and inactive destinations cannot move a window."""
        self.two_displays()
        self.windows = [window("current")]
        for displays in (
            [{"id": "other"}, {"id": "another"}],
            [self.displays[0], self.displays[0]],
            [self.displays[0], {"id": "display:2"}],
        ):
            with self.subTest(displays=displays):
                self.displays = displays
                with self.assertRaises(window_action.WindowActionError):
                    self.act("send-monitor")
                self.assertEqual(self.commands, [])

    def test_monitor_workspace_must_belong_to_the_destination_screen(self):
        """Stale screen membership cannot redirect a send to the source display."""
        self.two_displays()
        self.windows = [window("current")]
        self.workspaces[1]["display"] = {"id": "display:1"}
        with self.assertRaises(window_action.WindowActionError):
            self.act("send-monitor")
        self.assertEqual(self.commands, [])

    def test_workspace_and_monitor_sends_reject_scratchpads_and_fullscreen(self):
        """Special windows retain their membership and geometry."""
        self.two_displays()
        for flags in ({"isScratchpad": True}, {"isFullscreen": True}):
            for arguments in (("send-workspace", "2"), ("send-monitor",)):
                with self.subTest(flags=flags, action=arguments):
                    self.windows = [window("special", **flags)]
                    with self.assertRaises(window_action.WindowActionError):
                        self.act(*arguments)
                    self.assertEqual(self.commands, [])
                    self.assertEqual(self.native.changes, [])

    def test_unmanaged_foreground_cannot_send_background_windows(self):
        """Sending a window requires a managed foreground target."""
        self.two_displays()
        self.native.pid = 999
        for arguments in (("send-workspace", "2"), ("send-monitor",)):
            self.act(*arguments)
            self.assertEqual(self.commands, [])

    def test_already_current_source_accepts_native_no_change(self):
        """An idempotent source-focus result succeeds after verifying the workspace."""
        self.two_displays()
        self.windows = [window("current")]
        self.workspaces[0]["isCurrent"] = True

        def already_current(*arguments):
            if arguments == ("workspace", "focus-name", "1"):
                self.commands.append(arguments)
                raise window_action.WindowActionError("ignored: no_change")
            return self.cli(*arguments)

        with mock.patch.object(window_action, "omniwm", side_effect=already_current):
            window_action.perform(["send-workspace", "2"], self.native)
        self.assertEqual(self.windows[0]["workspace"]["rawName"], "2")
        self.assertEqual(self.commands[-1], ("workspace", "focus-name", "1"))

    def test_failed_source_focus_is_reported_when_another_screen_is_current(self):
        """A visible source workspace cannot mask failure to restore its keyboard interaction."""
        self.two_displays()
        self.windows = [window("current")]
        self.workspaces[0].update(isCurrent=False, isVisible=True)
        self.workspaces[1]["isCurrent"] = True

        def failed_focus(*arguments):
            if arguments == ("workspace", "focus-name", "1"):
                raise window_action.WindowActionError("cannot focus source")
            return self.cli(*arguments)

        with (
            mock.patch.object(window_action, "omniwm", side_effect=failed_focus),
            self.assertRaisesRegex(
                window_action.WindowActionError, "cannot focus source"
            ),
        ):
            window_action.perform(["send-workspace", "2"], self.native)

    def test_failed_transfer_never_follows_the_target(self):
        """An ineffective native move is reported before destination activation."""
        self.two_displays()
        self.windows = [window("current")]

        def ineffective(*arguments):
            if arguments[:2] == ("window", "move-to-workspace"):
                self.commands.append(arguments)
                return "no_change"
            return self.cli(*arguments)

        with (
            mock.patch.object(window_action, "omniwm", side_effect=ineffective),
            self.assertRaisesRegex(window_action.WindowActionError, "did not reach"),
        ):
            window_action.perform(["send-monitor"], self.native)
        self.assertEqual(
            self.commands,
            [
                ("window", "navigate", "current"),
                ("window", "move-to-workspace", "current", "2"),
            ],
        )

    def test_floating_resize_changes_only_the_focused_window(self):
        """Width and height use display-relative steps without changing tiled columns."""
        for axis, direction, dimension, value in (
            ("horizontal", "grow", "width", 500),
            ("horizontal", "shrink", "width", 300),
            ("vertical", "grow", "height", 380),
            ("vertical", "shrink", "height", 220),
        ):
            with self.subTest(axis=axis, direction=direction):
                self.native = Accessibility()
                self.commands.clear()
                self.act("resize", axis, direction)
                target, frame = self.native.changes[0]
                self.assertEqual(target, "float")
                self.assertEqual(frame[dimension], value)
                self.assertEqual((frame["x"], frame["y"]), (100, 100))
                self.assertEqual(self.commands, [])

    def test_tiled_resize_keeps_native_commands(self):
        """Tiled width/height continue to use OmniWM's Niri sizing operations."""
        self.native.pid = 20
        for axis, direction, action, amount in (
            ("horizontal", "grow", "set-container-primary-span", "+10%"),
            ("vertical", "shrink", "set-window-secondary-span", "-10%"),
        ):
            with self.subTest(axis=axis):
                self.commands.clear()
                self.act("resize", axis, direction)
                self.assertEqual(
                    self.commands,
                    [("window", "navigate", "tile"), ("command", action, amount)],
                )
                self.assertEqual(self.native.changes, [])

    def test_single_float_does_not_focus_tiling(self):
        """Directional focus stays in the floating layer without wrapping."""
        for direction in ("left", "right", "up", "down"):
            with self.subTest(direction=direction):
                self.act("focus", direction)
                self.assertEqual(self.commands, [])
        self.assertEqual(self.native.changes, [])

    def test_float_focus_uses_axis_distance(self):
        """The nearest center on the requested axis wins, as in niri."""
        self.windows.extend(
            [
                window(
                    "near-axis",
                    pid=30,
                    frame={"x": 150, "y": 1000, "width": 400, "height": 300},
                ),
                window(
                    "near-diagonal",
                    pid=40,
                    frame={"x": 200, "y": 100, "width": 400, "height": 300},
                ),
            ]
        )
        self.act("focus", "right")
        self.assertEqual(self.commands, [("window", "focus", "near-axis")])

    def test_focus_ties_use_stacking_order(self):
        """Equal directional distances prefer the topmost floating window."""
        self.windows.extend(
            [
                window(
                    "back",
                    pid=30,
                    frame={"x": 200, "y": 100, "width": 400, "height": 300},
                ),
                window(
                    "front",
                    pid=40,
                    frame={"x": 200, "y": 500, "width": 400, "height": 300},
                ),
            ]
        )
        self.native.order = [40, 30, 10]
        self.act("focus", "right")
        self.assertEqual(self.commands, [("window", "focus", "front")])

    def test_parked_and_other_workspace_floats_are_excluded(self):
        """Hidden overlays and other workspaces are not directional focus candidates."""
        self.windows.extend(
            [
                window("parked", pid=30, hiddenReason="scratchpad", isVisible=False),
                window("other-workspace", pid=40, workspace={"rawName": "2"}),
                window("other-display", pid=50, display={"id": "display:2"}),
            ]
        )
        self.act("focus", "right")
        self.assertEqual(self.commands, [])

    def test_floating_vertical_edge_uses_workspace_navigation(self):
        """Reference Mod-J/K switches workspace when no vertical floating neighbor exists."""
        self.workspaces.extend(
            [
                {"rawName": "2", "number": 2, "display": {"id": "display:1"}},
                {"rawName": "3", "number": 3, "display": {"id": "display:2"}},
            ]
        )
        self.act("focus", "down")
        self.assertEqual(self.commands, [("workspace", "focus-name", "2")])
        self.commands.clear()
        self.act("focus", "up")
        self.assertEqual(self.commands, [])

    def test_same_app_native_window_overrides_tiled_focus_metadata(self):
        """An app's floating dialog can have focus while its tiled token remains selected."""
        self.windows = [window("tile", mode="tiling"), window(isFocused=False)]
        self.act("resize", "horizontal", "grow")
        self.assertEqual(self.native.changes[0][0], "float")
        self.assertEqual(self.commands, [])

    def test_cmd_n_terminal_routes_actions_after_its_title_changes(self):
        """A dynamic terminal title and different model bounds cannot block layout keys."""
        self.native.pid = 9310
        self.native.title = "~/projects/work"
        self.native.window_id = 3608
        self.native.frame = {"x": 21, "y": 51, "width": 1411, "height": 2488}
        self.windows = [
            window("main", mode="tiling", pid=9310, windowId=191, title="code/main"),
            window(
                "new",
                mode="tiling",
                pid=9310,
                windowId=3608,
                title="Alacritty",
                isFocused=False,
                frame={"x": 21, "y": 21, "width": 1411, "height": 2488},
            ),
        ]
        for arguments, expected in (
            (["focus", "left"], ["focus", "left"]),
            (["focus", "right"], ["focus", "right"]),
            (["focus", "up"], ["focus-window-or-workspace-up"]),
            (["focus", "down"], ["focus-window-or-workspace-down"]),
            (["maximize"], ["toggle-container-full-primary-span"]),
            (["resize", "horizontal", "grow"], ["set-container-primary-span", "+10%"]),
            (
                ["resize", "horizontal", "shrink"],
                ["set-container-primary-span", "-10%"],
            ),
        ):
            with self.subTest(action=arguments):
                self.commands.clear()
                self.act(*arguments)
                self.assertEqual(
                    self.commands,
                    [("window", "navigate", "new"), ("command", *expected)],
                )
                self.assertEqual(self.native.changes, [])

    def test_focused_sibling_still_synchronizes_niri_selection(self):
        """A focused-window flag does not guarantee the layout engine selected that window."""
        self.native.pid = 9310
        self.native.window_id = 3608
        self.windows = [
            window("main", mode="tiling", pid=9310, windowId=191, title="code/main"),
            window("new", mode="tiling", pid=9310, windowId=3608, title="Alacritty"),
        ]
        self.act("maximize")
        self.assertEqual(
            self.commands,
            [
                ("window", "navigate", "new"),
                ("command", "toggle-container-full-primary-span"),
            ],
        )

    def test_native_window_id_overrides_a_stale_title_match(self):
        """A cached title matching another window cannot redirect native focus identity."""
        self.windows = [
            window("wrong", mode="tiling", windowId=1),
            window("correct", mode="tiling", windowId=2, isFocused=False),
        ]
        self.native.title = "wrong"
        self.native.window_id = 2
        self.act("focus", "left")
        self.assertEqual(
            self.commands,
            [("window", "navigate", "correct"), ("command", "focus", "left")],
        )

    def test_unmanaged_native_window_id_cannot_select_a_same_app_window(self):
        """A recognized unmanaged window cannot fall back to a managed sibling's title."""
        self.windows = [window("float", windowId=1), window("sibling", windowId=2)]
        self.native.window_id = 999
        self.act("resize", "horizontal", "grow")
        self.assertEqual(self.commands, [])
        self.assertEqual(self.native.changes, [])

    def test_tiled_directional_focus_is_preserved(self):
        """Tiled up/down retain workspace traversal at the column edge."""
        self.native.pid = 20
        for direction, arguments in (
            ("left", ("focus", "left")),
            ("right", ("focus", "right")),
            ("up", ("focus-window-or-workspace-up",)),
            ("down", ("focus-window-or-workspace-down",)),
        ):
            with self.subTest(direction=direction):
                self.commands.clear()
                self.act("focus", direction)
                self.assertEqual(
                    self.commands,
                    [("window", "navigate", "tile"), ("command", *arguments)],
                )

    def test_stale_tiled_focus_is_synchronized(self):
        """The foreground app takes precedence over stale WM focus metadata."""
        self.native.pid = 20
        self.windows[0]["isFocused"] = False
        self.act("focus", "right")
        self.assertEqual(
            self.commands,
            [
                ("window", "navigate", "tile"),
                ("command", "focus", "right"),
            ],
        )

    def test_unmanaged_foreground_cannot_change_the_background(self):
        """Missing foreground ownership causes no layout or geometry action."""
        self.native.pid = 999
        self.act("resize", "horizontal", "grow")
        self.assertEqual(self.commands, [])
        self.assertEqual(self.native.changes, [])

    def test_duplicate_app_titles_do_not_select_arbitrarily(self):
        """Ambiguous same-app windows cannot cause a resize of the wrong layer."""
        self.windows = [window(), window("duplicate", pid=10, title="float")]
        with self.assertRaises(window_action.WindowActionError):
            self.act("resize", "horizontal", "grow")
        self.assertEqual(self.commands, [])
        self.assertEqual(self.native.changes, [])

    def test_floating_width_presets_cycle_without_tiling_commands(self):
        """Presets resize the focused float and wrap after 90 percent."""
        for expected in (500, 750, 900, 500):
            self.act("cycle-width")
            self.assertEqual(self.native.frame["width"], expected)
        self.assertEqual(self.commands, [])

    def test_floating_movement_uses_reference_step(self):
        """Horizontal movement steps by 5% of the usable screen width."""
        self.act("move", "left")
        self.assertEqual(self.native.frame["x"], 50)
        self.act("move", "right")
        self.assertEqual(self.native.frame["x"], 100)
        self.assertEqual(self.commands, [])

    def test_floating_vertical_movement_uses_reference_step(self):
        """Vertical movement steps by 5% of the usable screen height."""
        self.act("move", "up")
        self.assertEqual(self.native.frame["y"], 60)
        self.act("move", "down")
        self.assertEqual(self.native.frame["y"], 100)
        self.assertEqual(self.native.frame["x"], 100)
        self.assertEqual(self.commands, [])

    def test_floating_movement_keeps_the_window_onscreen(self):
        """Directional movement clamps the whole float inside an inset screen."""
        self.native.frame["x"] = -300
        self.act("move", "left")
        self.assertEqual(self.native.frame["x"], 5)
        self.native.frame["x"] = 900
        self.act("move", "right")
        self.assertEqual(self.native.frame["x"], 595)
        self.native.frame["y"] = -300
        self.act("move", "up")
        self.assertEqual(self.native.frame["y"], 25)
        self.native.frame["y"] = 950
        self.act("move", "down")
        self.assertEqual(self.native.frame["y"], 515)

    def test_floating_resize_keeps_the_window_onscreen(self):
        """Growing or cycling width clamps the whole float inside the screen."""
        self.native.frame.update(x=700, y=600)
        self.act("resize", "horizontal", "grow")
        self.assertEqual(self.native.frame["width"], 500)
        self.assertEqual(self.native.frame["x"], 495)
        self.assertEqual(self.native.frame["y"], 515)
        self.act("resize", "vertical", "grow")
        self.assertEqual(self.native.frame["height"], 380)
        self.assertEqual(self.native.frame["y"], 435)
        self.act("cycle-width")
        self.assertEqual(self.native.frame["width"], 750)
        self.assertEqual(self.native.frame["x"], 245)

    def test_switch_layer_restores_tiled_or_floating_focus(self):
        """The explicit layer shortcut works even with only one overlay."""
        self.act("switch-layer")
        self.assertEqual(
            self.commands,
            [
                ("window", "focus", "float"),
                ("command", "toggle-floating-focus"),
            ],
        )
        self.commands.clear()
        self.native.pid = 20
        self.act("switch-layer")
        self.assertEqual(self.commands, [("window", "focus", "float")])

    def test_tiled_routing_defers_unused_native_bindings(self):
        """Tiled shortcuts load AX and window-list bindings only when required."""
        with mock.patch.object(
            window_action.importlib, "import_module", side_effect=lambda name: name
        ) as imported:
            native = window_action.Accessibility()
            self.assertEqual(
                imported.call_args_list,
                [mock.call("AppKit"), mock.call("CoreFoundation")],
            )
            self.assertEqual(native.ax, "ApplicationServices")
            self.assertEqual(native.ax, "ApplicationServices")
            self.assertEqual(native.quartz, "Quartz")
            self.assertEqual(native.quartz, "Quartz")
            self.assertEqual(imported.call_count, 4)

    def test_native_foreground_observation_processes_notifications(self):
        """AppKit focus notifications must be processed before reading its cached app."""
        native = window_action.Accessibility.__new__(window_action.Accessibility)
        native.cf = mock.Mock()
        native.appkit = mock.Mock()
        state = {"pid": 10}
        application = native.appkit.NSWorkspace.sharedWorkspace.return_value.frontmostApplication.return_value
        application.processIdentifier.side_effect = lambda: state["pid"]

        def refresh(*_args):
            state["pid"] = 20

        native.cf.CFRunLoopRunInMode.side_effect = refresh
        self.assertEqual(native.foreground_pid(), 20)

    def test_native_window_lookup_uses_pid_and_actual_window_server_bounds(self):
        """WindowServer IDs are matched against native bounds rather than WM title caches."""
        native = window_action.Accessibility.__new__(window_action.Accessibility)
        native.quartz = mock.Mock()
        native.quartz.kCGWindowOwnerPID = "pid"
        native.quartz.kCGWindowBounds = "bounds"
        native.quartz.kCGWindowNumber = "number"
        bounds = {"X": 21, "Y": 51, "Width": 1411, "Height": 2488}
        native.quartz.CGWindowListCopyWindowInfo.return_value = [
            {"pid": 20, "number": 7, "bounds": bounds},
            {
                "pid": 9310,
                "number": 8,
                "bounds": {"X": 0, "Y": 0, "Width": 0, "Height": 0},
            },
            {"pid": 9310, "number": 191, "bounds": {**bounds, "Width": 2267}},
            {"pid": 9310, "number": 3608, "bounds": bounds},
        ]
        frame = {"x": 21, "y": 51, "width": 1411, "height": 2488}
        self.assertEqual(native.window_id(9310, frame), 3608)
        native.quartz.CGWindowListCopyWindowInfo.return_value.append(
            {"pid": 9310, "number": 3609, "bounds": bounds}
        )
        self.assertIsNone(native.window_id(9310, frame))

    def test_native_identity_does_not_require_a_title_when_window_id_is_known(self):
        """A native window ID is sufficient even when a title attribute is unavailable."""
        native = window_action.Accessibility.__new__(window_action.Accessibility)
        native.foreground_pid = mock.Mock(return_value=9310)
        native.focused_element = mock.Mock(return_value=object())
        native.geometry = mock.Mock(return_value=self.native.frame.copy())
        native.window_id = mock.Mock(return_value=3608)
        native.attribute = mock.Mock(
            side_effect=window_action.WindowActionError("No title")
        )
        self.assertEqual(native.focused_identity()["windowId"], 3608)
        native.attribute.assert_not_called()

    def test_native_floating_frame_validation_uses_window_id(self):
        """Floating geometry also accepts dynamic titles while rejecting a different window."""
        for actual_id in (3608, 191):
            with self.subTest(actual_id=actual_id):
                native = window_action.Accessibility.__new__(
                    window_action.Accessibility
                )
                native.target = None
                element = object()
                native.focused_element = mock.Mock(return_value=element)
                native.geometry = mock.Mock(return_value=self.native.frame.copy())
                native.window_id = mock.Mock(return_value=actual_id)
                native.attribute = mock.Mock(return_value="~/projects/work")
                target = window(pid=9310, windowId=3608, title="Alacritty")
                if actual_id == 3608:
                    self.assertEqual(native.read_frame(target), self.native.frame)
                    self.assertEqual(native.target, (9310, element))
                else:
                    with self.assertRaises(window_action.WindowActionError):
                        native.read_frame(target)
                    self.assertIsNone(native.target)
                native.attribute.assert_not_called()

    def test_native_geometry_rejects_changed_focus(self):
        """The real AX adapter checks element identity before changing geometry."""
        native = window_action.Accessibility.__new__(window_action.Accessibility)
        native.target = (10, object())
        native.focused_element = mock.Mock(return_value=object())
        native.cf = mock.Mock()
        native.cf.CFEqual.return_value = False
        native.geometry = mock.Mock()
        with self.assertRaises(window_action.WindowActionError):
            native.write_frame(self.windows[1], self.native.frame)
        native.geometry.assert_not_called()

    def test_native_resize_avoids_edge_clipping_and_restores_position(self):
        """AX sizing clips at monitor edges, but temporary positioning permits the requested size."""
        for fail_resize in (False, True):
            with self.subTest(fail_resize=fail_resize):
                native = window_action.Accessibility.__new__(
                    window_action.Accessibility
                )
                element = object()
                native.target = (10, element)
                native.focused_element = mock.Mock(return_value=element)
                native.cf = mock.Mock()
                native.cf.CFEqual.return_value = True
                frame = {"x": 400, "y": 50, "width": 400, "height": 300}
                original = frame.copy()
                requested = {**frame, "width": 800}
                native.geometry = mock.Mock(
                    side_effect=lambda _, frame=frame: frame.copy()
                )
                native.working_area = mock.Mock(
                    return_value={"x": 0, "y": 20, "width": 1000, "height": 800}
                )
                native.ax = mock.Mock()
                native.ax.kAXPositionAttribute = "position"
                native.ax.AXValueCreate.side_effect = lambda _kind, value: value

                def set_attribute(
                    _element, attribute, value, frame=frame, fail_resize=fail_resize
                ):
                    if attribute == "position":
                        frame["x"], frame["y"] = value
                    elif fail_resize:
                        return -25200
                    else:
                        frame["width"] = min(value[0], 1000 - frame["x"])
                        frame["height"] = value[1]
                    return 0

                native.ax.AXUIElementSetAttributeValue.side_effect = set_attribute
                if fail_resize:
                    with self.assertRaises(window_action.WindowActionError):
                        native.write_frame(self.windows[1], requested)
                    self.assertEqual(frame, original)
                else:
                    native.write_frame(self.windows[1], requested)
                    self.assertEqual(frame, requested)

    def test_native_geometry_requires_accessibility(self):
        """Missing permission produces a clear error before any window request."""
        native = window_action.Accessibility.__new__(window_action.Accessibility)
        native.ax = mock.Mock()
        native.ax.AXIsProcessTrusted.return_value = False
        native.foreground_pid = mock.Mock()
        with self.assertRaises(window_action.WindowActionError):
            native.focused_element(10)
        native.foreground_pid.assert_not_called()

    def test_center_float_centers_both_axes(self):
        """Niri's center-column command centers a floating window in the working area."""
        self.act("center")
        self.assertEqual(
            self.native.frame, {"x": 300, "y": 270, "width": 400, "height": 300}
        )
        self.assertEqual(self.commands, [])

    def test_maximize_column_ignores_floating_focus(self):
        """Niri leaves floating windows unchanged for maximize-column."""
        self.act("maximize")
        self.assertEqual(self.commands, [])
        self.assertEqual(self.native.changes, [])

    def test_tab_cycle_wraps_within_the_current_group(self):
        """Group cycling uses native local-wrap commands after synchronizing real focus."""
        self.native.pid = 20
        for focused in (True, False):
            self.windows[0]["isFocused"] = focused
            for direction, target in (
                ("forward", "down-or-top"),
                ("backward", "up-or-bottom"),
            ):
                with self.subTest(focused=focused, direction=direction):
                    self.commands.clear()
                    self.act("cycle-tabs", direction)
                    expected = [("window", "navigate", "tile")]
                    self.assertEqual(
                        self.commands, [*expected, ("command", "focus-window", target)]
                    )
                    self.assertEqual(self.native.changes, [])

    def test_floating_or_unmanaged_focus_cannot_cycle_background_tabs(self):
        """Group cycling leaves background columns unchanged when they lack keyboard focus."""
        for pid in (10, 999):
            self.native.pid = pid
            for direction in ("forward", "backward"):
                with self.subTest(pid=pid, direction=direction):
                    self.act("cycle-tabs", direction)
                    self.assertEqual(self.commands, [])
                    self.assertEqual(self.native.changes, [])

    def test_tiled_column_tabbed_toggle(self):
        """Tabbed display uses native column state after synchronizing real focus."""
        self.native.pid = 20
        for focused in (True, False):
            with self.subTest(focused=focused):
                self.windows[0]["isFocused"] = focused
                self.commands.clear()
                self.act("toggle-tabs")
                expected = [("window", "navigate", "tile")]
                self.assertEqual(
                    self.commands, [*expected, ("command", "toggle-column-tabbed")]
                )
                self.assertEqual(self.native.changes, [])

    def test_floating_or_unmanaged_focus_cannot_toggle_background_tabs(self):
        """Tabbed display never changes a column behind an overlay or unmanaged app."""
        for pid in (10, 999):
            with self.subTest(pid=pid):
                self.native.pid = pid
                self.act("toggle-tabs")
                self.assertEqual(self.commands, [])
                self.assertEqual(self.native.changes, [])

    def test_hidden_tab_cannot_override_the_visible_foreground_window(self):
        """A remembered inactive tab cannot redirect a group action."""
        self.native.pid = 20
        self.windows[0]["isFocused"] = False
        self.windows.insert(
            0,
            window(
                "hidden-tab",
                mode="tiling",
                pid=20,
                isVisible=False,
                hiddenReason="tab-inactive",
            ),
        )
        for arguments, command in (
            (["toggle-tabs"], ("command", "toggle-column-tabbed")),
            (["cycle-tabs", "forward"], ("command", "focus-window", "down-or-top")),
            (["cycle-tabs", "backward"], ("command", "focus-window", "up-or-bottom")),
        ):
            with self.subTest(action=arguments):
                self.commands.clear()
                self.act(*arguments)
                self.assertEqual(
                    self.commands, [("window", "navigate", "tile"), command]
                )
                self.assertEqual(self.native.changes, [])

    def test_tiled_column_merge_and_split(self):
        """Column changes use native operations after synchronizing real tiled focus."""
        self.native.pid = 20
        for focused in (True, False):
            self.windows[0]["isFocused"] = focused
            for action, command in (
                ("merge", "consume-window-into-column"),
                ("split", "expel-window-from-column"),
            ):
                with self.subTest(action=action, focused=focused):
                    self.commands.clear()
                    self.act(action)
                    expected = [("window", "navigate", "tile")]
                    self.assertEqual(self.commands, [*expected, ("command", command)])
                    self.assertEqual(self.native.changes, [])

    def test_floating_focus_cannot_merge_or_split_background_columns(self):
        """Column membership keys leave floating focus and tiled columns unchanged."""
        for action in ("merge", "split"):
            with self.subTest(action=action):
                self.act(action)
                self.assertEqual(self.commands, [])
                self.assertEqual(self.native.changes, [])

    def test_unmanaged_foreground_cannot_merge_or_split_columns(self):
        """Column keys do nothing when no managed foreground window exists."""
        self.native.pid = 999
        for action in ("merge", "split"):
            with self.subTest(action=action):
                self.act(action)
                self.assertEqual(self.commands, [])
                self.assertEqual(self.native.changes, [])

    def test_space_navigation_synthesizes_the_recorded_hotkey(self):
        """Space navigation posts the arrow hotkey with a HID source and fn flag."""
        posted = []

        class FakeEvent:
            pass

        fake = mock.Mock()
        fake.kCGEventSourceStateHIDSystemState = 0
        fake.kCGHIDEventTap = 0
        fake.CGEventCreateKeyboardEvent.side_effect = lambda source, keycode, pressed: (
            posted.append((keycode, pressed))
        )
        for direction, keycode in (("left", 123), ("right", 124)):
            with self.subTest(direction=direction):
                posted.clear()
                with mock.patch.dict(sys.modules, {"Quartz": fake}):
                    self.act("space", direction)
                self.assertEqual(posted, [(keycode, True), (keycode, False)])
                self.assertEqual(self.commands, [])
                self.assertEqual(fake.CGEventSourceCreate.call_count, 1)
                self.assertEqual(fake.CGEventSetFlags.call_args.args[1], 0x8E0000)
                fake.CGEventSourceCreate.reset_mock()
                fake.CGEventSetFlags.reset_mock()

    def test_floating_move_max_aligns_one_edge_with_the_screen(self):
        """Shifted movement snaps the leading edge to the inset screen border."""
        expectations = {
            "left": {"x": 5},
            "right": {"x": 595},
            "up": {"y": 25},
            "down": {"y": 515},
        }
        for direction, expected in expectations.items():
            with self.subTest(direction=direction):
                self.native.frame.update(x=100, y=100)
                self.act("move-max", direction)
                for key, value in expected.items():
                    self.assertEqual(self.native.frame[key], value)

    def test_tiled_move_max_reorders_to_the_ends(self):
        """Shifted tiled movement maps to first/last, vertical stays a step."""
        self.native.pid = 20
        for direction, expected in (
            ("left", ("move-column-to-first",)),
            ("right", ("move-column-to-last",)),
            ("up", ("move-column", "up")),
            ("down", ("move-column", "down")),
        ):
            with self.subTest(direction=direction):
                self.commands.clear()
                self.act("move-max", direction)
                self.assertEqual(
                    self.commands,
                    [("window", "navigate", "tile"), ("command",) + expected],
                )

    def test_tiled_layout_operations_are_preserved(self):
        """Other tiled operations retain their existing native actions."""
        self.native.pid = 20
        for arguments, expected in (
            (["move", "left"], ("move-column", "left")),
            (["move", "up"], ("move-column", "up")),
            (["move", "down"], ("move-column", "down")),
            (["center"], ("center-column",)),
            (["maximize"], ("toggle-container-full-primary-span",)),
            (["cycle-width"], ("cycle-size", "forward")),
        ):
            with self.subTest(action=arguments):
                self.commands.clear()
                self.act(*arguments)
                self.assertEqual(
                    self.commands,
                    [("window", "navigate", "tile"), ("command", *expected)],
                )

    def test_invalid_query_is_rejected(self):
        """Malformed IPC data cannot route a command to a remembered column."""
        for payload in ("{", '{"ok": false}', '{"ok":true}'):
            with (
                self.subTest(payload=payload),
                mock.patch.object(window_action, "omniwm", return_value=payload),
                self.assertRaises(window_action.WindowActionError),
            ):
                window_action.perform(["focus", "left"], self.native)
        self.assertEqual(self.native.changes, [])

    def test_resize_respects_positive_dimensions(self):
        """Repeated shrinking cannot request a nonpositive native size."""
        self.native.frame["width"] = 1
        self.act("resize", "horizontal", "shrink")
        self.assertGreaterEqual(self.native.frame["width"], 1)

    def test_focus_change_during_native_resize_is_reported(self):
        """Native target validation can abort a mutation without touching tiling."""
        with (
            mock.patch.object(
                self.native,
                "write_frame",
                side_effect=window_action.WindowActionError("Focus changed"),
            ),
            self.assertRaises(window_action.WindowActionError),
        ):
            self.act("resize", "horizontal", "grow")
        self.assertEqual(self.commands, [])


if __name__ == "__main__":
    unittest.main()
