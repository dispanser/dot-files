"""Exercise fixed terminal roles without starting applications or touching tmux."""

import contextlib
import copy
import fcntl
import importlib.util
import io
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest import mock

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/terminal.py"
spec = importlib.util.spec_from_file_location("omniwm_terminal", SCRIPT)
terminal = importlib.util.module_from_spec(spec)


def window(role="main", *, focused=False, workspace="1", **overrides):
    """Build a normal Alacritty window query snapshot."""
    return {
        "id": f"ow_{role}",
        "app": {"bundleId": "org.alacritty"},
        "title": f"code/{role}",
        "workspace": {"rawName": workspace},
        "isFocused": focused,
        "isVisible": True,
        "isScratchpad": False,
        **overrides,
    }


class Desktop:
    """Simulate the documented OmniWM actions used by terminal roles."""

    def __init__(self, windows=()):
        self.windows = copy.deepcopy(list(windows))
        self.actions = []
        self.spawns = []
        self.focus_works = True
        self.spawn_works = True
        self.spawn_workspace = "1"
        self.assignment_works = True
        self.parking_works = True

    def cli(self, *args):
        """Serve snapshots and apply actions to the simulated desktop."""
        if args[0] == "query":
            payload = (
                {"windows": self.windows}
                if args[1] == "windows"
                else {"workspace": {"rawName": "1"}}
            )
            return json.dumps({"ok": True, "result": {"payload": payload}})
        self.actions.append(args)
        if args[:2] == ("window", "move-to-workspace"):
            target = next(w for w in self.windows if w["id"] == args[2])
            target["workspace"]["rawName"] = args[3]
        elif args[:2] == ("window", "navigate"):
            if self.focus_works:
                for item in self.windows:
                    item["isFocused"] = item["id"] == args[2]
        elif args[:2] == ("window", "focus"):
            if self.focus_works:
                for item in self.windows:
                    item["isFocused"] = item["id"] == args[2]
                    if item["isFocused"]:
                        item.update(isAppHidden=False, isVisible=True)
                        item.pop("hiddenReason", None)
        elif args[:3] == ("command", "scratchpad", "assign"):
            target = next(w for w in self.windows if w["isFocused"])
            if self.assignment_works:
                target.update(
                    isScratchpad=True,
                    scratchpadIndex=1,
                    isVisible=False,
                    isFocused=False,
                    hiddenReason="scratchpad",
                )
        elif args[:3] == ("command", "scratchpad", "toggle"):
            if not self.parking_works:
                return "executed"
            target = next(w for w in self.windows if w.get("scratchpadIndex") == 1)
            reveal = (
                target.get("hiddenReason") == "scratchpad"
                or target["workspace"]["rawName"] != "1"
            )
            target.update(isVisible=reveal, isFocused=reveal)
            target["workspace"]["rawName"] = "1"
            if reveal:
                target.pop("hiddenReason", None)
            else:
                target["hiddenReason"] = "scratchpad"
        else:
            raise RuntimeError(f"Unexpected desktop action: {args}")
        return "executed"

    def spawn(self, role, directory, logs):
        """Publish a new terminal window without launching a process."""
        self.spawns.append((role, directory, logs))
        if self.spawn_works:
            self.windows.append(
                window(role, focused=True, workspace=self.spawn_workspace)
            )


class TerminalTests(unittest.TestCase):
    """Protect session reuse, overlay toggling, and focus-sensitive assignment."""

    @classmethod
    def setUpClass(cls):
        """Load the private helper without executing its command-line entry."""
        spec.loader.exec_module(terminal)

    def setUp(self):
        """Give each test a private existing working directory."""
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)

    def activate(self, desktop, role):
        """Run policy against the simulated desktop without waiting."""
        with (
            mock.patch.object(terminal, "omniwm", side_effect=desktop.cli),
            mock.patch.object(terminal, "spawn_terminal", side_effect=desktop.spawn),
            mock.patch.object(terminal.time, "sleep"),
        ):
            terminal.activate_terminal(role, self.directory, self.directory)

    def park(self, desktop, unless_window=None):
        """Run the hide-only policy without launching clients or waiting."""
        with (
            mock.patch.object(terminal, "omniwm", side_effect=desktop.cli),
            mock.patch.object(terminal.time, "sleep"),
        ):
            terminal.park_overlay(unless_window)

    def test_parking_a_visible_overlay_is_idempotent(self):
        """Only the owned revealed overlay is parked, regardless of keyboard focus."""
        for focused in (True, False):
            with self.subTest(focused=focused):
                desktop = Desktop(
                    [
                        window(
                            "overlay",
                            focused=focused,
                            isScratchpad=True,
                            scratchpadIndex=1,
                        )
                    ]
                )
                self.park(desktop)
                self.park(desktop)
                self.assertEqual(
                    desktop.actions, [("command", "scratchpad", "toggle", "1")]
                )
                self.assertFalse(desktop.windows[0]["isVisible"])
                self.assertEqual(desktop.spawns, [])

    def test_parked_overlay_can_be_summoned_without_recreation(self):
        """Mod-O reuses the same window after leaving it for another application."""
        desktop = Desktop([window("overlay", isScratchpad=True, scratchpadIndex=1)])
        self.park(desktop)
        self.activate(desktop, "overlay")
        self.assertTrue(desktop.windows[0]["isVisible"])
        self.assertEqual(desktop.windows[0]["id"], "ow_overlay")
        self.assertEqual(desktop.spawns, [])

    def test_parking_preserves_ineligible_windows(self):
        """Missing, unassigned, suspended, foreign, or off-workspace windows are untouched."""
        for snapshots in (
            [],
            [window("other", isScratchpad=True, scratchpadIndex=1)],
            [window("overlay")],
            [window("overlay", isScratchpad=True, scratchpadIndex=2)],
            [
                window(
                    "overlay",
                    isScratchpad=True,
                    scratchpadIndex=1,
                    isVisible=False,
                    hiddenReason="scratchpad",
                )
            ],
            [window("overlay", isScratchpad=True, scratchpadIndex=1, isAppHidden=True)],
            [
                window(
                    "overlay", isScratchpad=True, scratchpadIndex=1, isFullscreen=True
                )
            ],
            [window("overlay", workspace="2", isScratchpad=True, scratchpadIndex=1)],
        ):
            with self.subTest(windows=snapshots):
                desktop = Desktop(snapshots)
                self.park(desktop)
                self.assertEqual(desktop.actions, [])
                self.assertEqual(desktop.spawns, [])

    def test_parking_preserves_the_selected_overlay(self):
        """App cycling can explicitly select the overlay without dismissing it."""
        desktop = Desktop([window("overlay", isScratchpad=True, scratchpadIndex=1)])
        self.park(desktop, unless_window="ow_overlay")
        self.assertEqual(desktop.actions, [])
        self.assertTrue(desktop.windows[0]["isVisible"])

    def test_parking_refuses_foreign_slot_members(self):
        """Automatic dismissal cannot park another window sharing the reserved slot."""
        desktop = Desktop(
            [
                window("overlay", isScratchpad=True, scratchpadIndex=1),
                window("other", isScratchpad=True, scratchpadIndex=1),
            ]
        )
        with self.assertRaises(terminal.TerminalError):
            self.park(desktop)
        self.assertEqual(desktop.actions, [])

    def test_parking_requires_confirmed_hidden_state(self):
        """An ineffective native toggle reports failure without toggling a second time."""
        desktop = Desktop([window("overlay", isScratchpad=True, scratchpadIndex=1)])
        desktop.parking_works = False
        with self.assertRaises(terminal.TerminalError):
            self.park(desktop)
        self.assertEqual(desktop.actions, [("command", "scratchpad", "toggle", "1")])

    def test_main_selection_parks_the_overlay_first(self):
        """Mod-T leaves the overlay layer before focusing the main terminal."""
        desktop = Desktop(
            [
                window(),
                window("overlay", focused=True, isScratchpad=True, scratchpadIndex=1),
            ]
        )
        self.activate(desktop, "main")
        self.assertEqual(
            desktop.actions,
            [
                ("command", "scratchpad", "toggle", "1"),
                ("window", "navigate", "ow_main"),
            ],
        )
        self.assertEqual(desktop.spawns, [])

    def test_busy_terminal_lock_cancels_automatic_parking(self):
        """An app shortcut must not continue while a concurrent Mod-O can reveal the overlay."""
        cache = self.directory / "omniwm"
        cache.mkdir()
        with (
            (cache / "terminal.lock").open("a") as lock,
            mock.patch.dict(os.environ, {"XDG_CACHE_HOME": str(self.directory)}),
            contextlib.redirect_stderr(io.StringIO()) as error,
        ):
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            self.assertEqual(terminal.main(["focus-app", "--window", "ow_slack"]), 1)
            self.assertIn("application switch cancelled", error.getvalue())

    def test_main_adopts_existing_window(self):
        """An existing code/main window is focused without spawning a client."""
        desktop = Desktop([window()])
        self.activate(desktop, "main")
        self.assertEqual(desktop.actions, [("window", "navigate", "ow_main")])
        self.assertEqual(desktop.spawns, [])

    def test_new_main_uses_the_invocation_workspace(self):
        """An application restore destination cannot override the requested workspace."""
        desktop = Desktop()
        desktop.spawn_workspace = "2"
        self.activate(desktop, "main")
        self.assertEqual(
            desktop.actions,
            [
                ("window", "move-to-workspace", "ow_main", "1"),
                ("window", "navigate", "ow_main"),
            ],
        )

    def test_focused_main_is_unchanged(self):
        """Repeated Mod-T leaves the terminal focused while MRU is deferred."""
        desktop = Desktop([window(focused=True)])
        self.activate(desktop, "main")
        self.assertEqual(desktop.actions, [])
        self.assertEqual(desktop.spawns, [])

    def test_main_is_brought_to_current_workspace(self):
        """Focus follows the terminal after bringing it to the invocation workspace."""
        desktop = Desktop([window(workspace="2")])
        self.activate(desktop, "main")
        self.assertEqual(
            desktop.actions,
            [
                ("window", "move-to-workspace", "ow_main", "1"),
                ("window", "navigate", "ow_main"),
            ],
        )

    def test_missing_main_is_spawned_once(self):
        """Missing windows create one client for the existing or new session."""
        desktop = Desktop()
        self.activate(desktop, "main")
        self.activate(desktop, "main")
        self.assertEqual(desktop.spawns, [("main", self.directory, self.directory)])

    def test_overlay_is_assigned_revealed_hidden_and_revealed_again(self):
        """The first trigger creates an overlay; later triggers toggle its visibility."""
        desktop = Desktop()
        self.activate(desktop, "overlay")
        self.assertTrue(desktop.windows[0]["isVisible"])
        self.activate(desktop, "overlay")
        self.assertFalse(desktop.windows[0]["isVisible"])
        self.activate(desktop, "overlay")
        self.assertTrue(desktop.windows[0]["isVisible"])
        self.assertEqual(len(desktop.spawns), 1)
        self.assertEqual(
            desktop.actions.count(("command", "scratchpad", "assign", "1")), 1
        )

    def test_visible_unfocused_overlay_is_focused(self):
        """An unfocused visible overlay is focused without hiding it."""
        desktop = Desktop([window("overlay", isScratchpad=True, scratchpadIndex=1)])
        self.activate(desktop, "overlay")
        self.assertEqual(desktop.actions, [("window", "navigate", "ow_overlay")])

    def test_hidden_overlay_is_restored_without_spawning(self):
        """Mac-hidden windows are restored through OmniWM's explicit focus action."""
        desktop = Desktop(
            [
                window(
                    "overlay",
                    isScratchpad=True,
                    scratchpadIndex=1,
                    isAppHidden=True,
                    isVisible=False,
                )
            ]
        )
        self.activate(desktop, "overlay")
        self.assertEqual(desktop.actions, [("window", "focus", "ow_overlay")])
        self.assertEqual(desktop.spawns, [])
        self.assertTrue(desktop.windows[0]["isVisible"])

    def test_hidden_unassigned_overlay_is_adopted(self):
        """A hidden window after restart is restored and assigned on the first trigger."""
        desktop = Desktop([window("overlay", isAppHidden=True, isVisible=False)])
        self.activate(desktop, "overlay")
        self.assertIn(("window", "focus", "ow_overlay"), desktop.actions)
        self.assertIn(("command", "scratchpad", "assign", "1"), desktop.actions)
        self.assertEqual(desktop.spawns, [])
        self.activate(desktop, "overlay")
        self.assertFalse(desktop.windows[0]["isVisible"])

    def test_failed_unhide_does_not_spawn(self):
        """Failure to restore an existing window cannot create a duplicate."""
        desktop = Desktop(
            [
                window(
                    "overlay",
                    isScratchpad=True,
                    scratchpadIndex=1,
                    isAppHidden=True,
                    isVisible=False,
                )
            ]
        )
        desktop.focus_works = False
        with self.assertRaises(terminal.TerminalError):
            self.activate(desktop, "overlay")
        self.assertEqual(desktop.actions, [("window", "focus", "ow_overlay")])
        self.assertEqual(desktop.spawns, [])

    def test_closed_overlay_is_recreated_once(self):
        """Closing a GUI window permits one new client for the same tmux session."""
        desktop = Desktop()
        self.activate(desktop, "overlay")
        desktop.windows.clear()
        self.activate(desktop, "overlay")
        self.activate(desktop, "overlay")
        self.assertEqual(len(desktop.spawns), 2)
        self.assertEqual(
            desktop.actions.count(("command", "scratchpad", "assign", "1")), 2
        )

    def test_hidden_main_is_restored(self):
        """Mod-T restores an existing hidden main terminal, even with stale focus metadata."""
        desktop = Desktop([window(focused=True, isAppHidden=True, isVisible=False)])
        self.activate(desktop, "main")
        self.assertEqual(desktop.actions, [("window", "focus", "ow_main")])
        self.assertEqual(desktop.spawns, [])

    def test_overlay_on_another_workspace_is_summoned(self):
        """Native scratchpads can be summoned to the invocation workspace."""
        desktop = Desktop(
            [window("overlay", workspace="2", isScratchpad=True, scratchpadIndex=1)]
        )
        self.activate(desktop, "overlay")
        self.assertEqual(desktop.actions, [("command", "scratchpad", "toggle", "1")])
        self.assertTrue(desktop.windows[0]["isVisible"])

    def test_overlay_membership_is_reconstructed(self):
        """After an OmniWM restart the existing window is assigned without respawning."""
        desktop = Desktop([window("overlay")])
        self.activate(desktop, "overlay")
        self.assertEqual(desktop.spawns, [])
        self.assertIn(("command", "scratchpad", "assign", "1"), desktop.actions)

    def test_occupied_slot_is_not_modified(self):
        """A slot containing another window is left untouched."""
        desktop = Desktop([window("other", isScratchpad=True, scratchpadIndex=1)])
        with self.assertRaises(terminal.TerminalError):
            self.activate(desktop, "overlay")
        self.assertEqual(desktop.actions, [])
        self.assertEqual(desktop.spawns, [])

    def test_overlay_in_another_slot_is_not_reassigned(self):
        """Manual assignments to other slots are preserved."""
        desktop = Desktop([window("overlay", isScratchpad=True, scratchpadIndex=2)])
        with self.assertRaises(terminal.TerminalError):
            self.activate(desktop, "overlay")
        self.assertEqual(desktop.actions, [])

    def test_assignment_requires_confirmed_focus(self):
        """A failed focus request never assigns an unrelated window to the slot."""
        desktop = Desktop([window("overlay")])
        desktop.focus_works = False
        with self.assertRaises(terminal.TerminalError):
            self.activate(desktop, "overlay")
        self.assertEqual(desktop.actions, [("window", "navigate", "ow_overlay")])

    def test_failed_assignment_is_not_toggled(self):
        """An assignment that does not take effect cannot reveal the wrong slot."""
        desktop = Desktop([window("overlay")])
        desktop.assignment_works = False
        with self.assertRaises(terminal.TerminalError):
            self.activate(desktop, "overlay")
        self.assertNotIn(("command", "scratchpad", "toggle", "1"), desktop.actions)

    def test_startup_wait_is_bounded(self):
        """Missing window admission reports an error after one launch attempt."""
        desktop = Desktop()
        desktop.spawn_works = False
        with self.assertRaises(terminal.TerminalError):
            self.activate(desktop, "overlay")
        self.assertEqual(len(desktop.spawns), 1)
        self.assertEqual(desktop.actions, [])

    def test_duplicate_titles_are_rejected(self):
        """Ambiguous owned windows are never selected arbitrarily."""
        desktop = Desktop([window(), window(id="ow_duplicate")])
        with self.assertRaises(terminal.TerminalError):
            self.activate(desktop, "main")
        self.assertEqual(desktop.actions, [])

    def test_missing_directory_does_not_spawn(self):
        """A missing working directory fails before creating a terminal client."""
        desktop = Desktop()
        self.directory /= "missing"
        with self.assertRaises(terminal.TerminalError):
            self.activate(desktop, "main")
        self.assertEqual(desktop.spawns, [])

    def test_malformed_query_is_rejected(self):
        """Malformed or incomplete IPC responses cannot cause terminal actions."""
        for response in ("{", '{"ok": false}', '{"ok": true}'):
            with (
                self.subTest(response=response),
                mock.patch.object(terminal, "omniwm", return_value=response),
                self.assertRaises(terminal.TerminalError),
            ):
                terminal.activate_terminal("main", self.directory, self.directory)

    def test_missing_active_workspace_is_reported(self):
        """An unavailable interaction workspace fails before terminal creation."""
        desktop = Desktop()
        original = desktop.cli

        def unavailable_workspace(*args):
            if args[:2] == ("query", "active-workspace"):
                return json.dumps(
                    {"ok": True, "result": {"payload": {"workspace": None}}}
                )
            return original(*args)

        with (
            mock.patch.object(terminal, "omniwm", side_effect=unavailable_workspace),
            mock.patch.object(terminal, "spawn_terminal") as spawn,
            self.assertRaises(terminal.TerminalError),
        ):
            terminal.activate_terminal("main", self.directory, self.directory)
        spawn.assert_not_called()

    def test_cli_errors_without_output_are_reported(self):
        """A silent failed CLI command still produces a fitting terminal error."""
        error = terminal.subprocess.CalledProcessError(1, ["omniwmctl"])
        with (
            mock.patch.object(terminal.subprocess, "run", side_effect=error),
            self.assertRaises(terminal.TerminalError),
        ):
            terminal.omniwm("query", "windows")

    def test_spawn_attaches_atomically_and_keeps_titles_fixed(self):
        """Only the new Alacritty client changes; existing tmux sessions are reused."""
        for role in ("main", "overlay"):
            with (
                self.subTest(role=role),
                mock.patch.object(terminal.subprocess, "Popen") as launch,
            ):
                executable = "/nix/store/test-alacritty/Applications/Alacritty.app/Contents/MacOS/alacritty"
                with mock.patch.dict(
                    os.environ,
                    {
                        "TMUX": "parent",
                        "TMUX_PANE": "%1",
                        "OMNIWM_ALACRITTY": executable,
                    },
                ):
                    terminal.spawn_terminal(role, self.directory, self.directory)
                arguments = launch.call_args.args[0]
                self.assertEqual(arguments[0], executable)
                self.assertEqual(
                    arguments[arguments.index("--title") + 1], f"code/{role}"
                )
                self.assertIn("window.dynamic_title=false", arguments)
                self.assertEqual(
                    arguments[arguments.index("--command") + 1 :],
                    [
                        "tmux",
                        "new-session",
                        "-A",
                        "-s",
                        f"code/{role}",
                        "-c",
                        str(self.directory),
                    ],
                )
                self.assertNotIn("TMUX", launch.call_args.kwargs["env"])
                self.assertNotIn("TMUX_PANE", launch.call_args.kwargs["env"])
                self.assertTrue(launch.call_args.kwargs["start_new_session"])
                if role == "overlay":
                    self.assertIn("window.dimensions.columns=90", arguments)
                    self.assertIn("window.dimensions.lines=22", arguments)

    def test_spawn_requires_a_bundle_executable(self):
        """An unconfigured helper cannot silently launch an unidentifiable app."""
        with (
            mock.patch.dict(os.environ, {"OMNIWM_ALACRITTY": ""}),
            mock.patch.object(terminal.subprocess, "Popen") as launch,
            self.assertRaises(terminal.TerminalError),
        ):
            terminal.spawn_terminal("overlay", self.directory, self.directory)
        launch.assert_not_called()

    def test_relative_cache_directory_uses_the_home_directory(self):
        """Invalid XDG paths cannot create lock files in the caller's directory."""
        with (
            contextlib.chdir(self.directory),
            mock.patch.dict(os.environ, {"XDG_CACHE_HOME": "relative"}),
            mock.patch.object(terminal.Path, "home", return_value=self.directory),
            mock.patch.object(terminal, "activate_terminal") as activate,
        ):
            self.assertEqual(terminal.main(["main"]), 0)
            self.assertEqual(
                activate.call_args.args[2], self.directory / ".cache/omniwm"
            )
            self.assertFalse((self.directory / "relative").exists())

    def test_held_lock_skips_duplicate_invocation(self):
        """Overlapping shortcuts cannot launch duplicate terminal clients."""
        cache = self.directory / "omniwm"
        cache.mkdir()
        with (cache / "terminal.lock").open("a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            with (
                mock.patch.dict(os.environ, {"XDG_CACHE_HOME": str(self.directory)}),
                mock.patch.object(terminal, "activate_terminal") as activate,
            ):
                self.assertEqual(terminal.main(["main"]), 0)
                activate.assert_not_called()


if __name__ == "__main__":
    unittest.main()
