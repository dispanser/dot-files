"""Test app focus against mocked OmniWM IPC without changing desktop state."""

import json
import os
import shlex
import subprocess
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/focus-app.fish"


class AppFocusTests(unittest.TestCase):
    """Protect exact app matching, stable cycling, and native activation."""

    def run_focus(
        self,
        windows,
        *args,
        query_status=0,
        navigate_status=0,
        open_status=0,
        park_status=0,
        payload=None,
    ):
        """Run the helper with an isolated CLI and record window actions."""
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            cli = root / "omniwmctl"
            cli.write_text(
                f"#!{sys.executable}\n"
                + textwrap.dedent("""\
                import json
                import os
                import sys
                from pathlib import Path

                args = sys.argv[1:]
                state = Path(os.environ["MOCK_PAYLOAD_FILE"])
                if args[:2] == ["query", "windows"]:
                    print(state.read_text())
                    sys.exit(int(os.environ["MOCK_QUERY_STATUS"]))
                if args[:2] == ["query", "active-workspace"]:
                    print(json.dumps({"ok": True, "result": {"payload": {"workspace": {"rawName": "1"}}}}))
                    sys.exit(0)
                with Path(os.environ["MOCK_LOG"]).open("a") as log:
                    if args[:2] == ["window", "navigate"]:
                        log.write(f"navigate:{args[2]}\\n")
                        sys.exit(int(os.environ["MOCK_NAVIGATE_STATUS"]))
                    if args[:3] == ["command", "scratchpad", "toggle"]:
                        log.write(f"park:{args[3]}\\n")
                        status = int(os.environ["MOCK_PARK_STATUS"])
                        if status:
                            sys.exit(status)
                        response = json.loads(state.read_text())
                        for window in response["result"]["payload"]["windows"]:
                            if window.get("scratchpadIndex") == int(args[3]):
                                hidden = window.get("hiddenReason") == "scratchpad"
                                window.update(isVisible=hidden, isFocused=hidden)
                                if hidden:
                                    window.pop("hiddenReason", None)
                                else:
                                    window["hiddenReason"] = "scratchpad"
                        state.write_text(json.dumps(response))
                        sys.exit(0)
                sys.exit(2)
                """)
            )
            cli.chmod(0o755)
            park = root / "omniwm-terminal"
            park.write_text(
                f"#!/bin/sh\nexec {shlex.quote(sys.executable)} "
                f'{shlex.quote(str(SCRIPT.with_name("terminal.py")))} "$@"\n'
            )
            park.chmod(0o755)
            native_open = root / "open"
            native_open.write_text(
                "#!/bin/sh\n"
                'printf "open:%s\\n" "$@" >> "$MOCK_LOG"\n'
                'exit "$MOCK_OPEN_STATUS"\n'
            )
            native_open.chmod(0o755)
            log = root / "actions.log"
            if payload is None:
                payload = json.dumps(
                    {
                        "ok": True,
                        "result": {"payload": {"windows": windows}},
                    }
                )
            state = root / "payload.json"
            state.write_text(payload)
            result = subprocess.run(
                ["fish", "--no-config", str(SCRIPT), *args],
                check=False,
                env={
                    **os.environ,
                    "PATH": directory + os.pathsep + os.environ["PATH"],
                    "MOCK_PAYLOAD_FILE": str(state),
                    "MOCK_PARK_STATUS": str(park_status),
                    "XDG_CACHE_HOME": str(root / "cache"),
                    "OMNIWM_ALACRITTY": str(root / "must-not-spawn"),
                    "MOCK_QUERY_STATUS": str(query_status),
                    "MOCK_NAVIGATE_STATUS": str(navigate_status),
                    "MOCK_OPEN_STATUS": str(open_status),
                    "MOCK_LOG": str(log),
                },
                capture_output=True,
                text=True,
                timeout=10,
            )
            try:
                self.last_windows = json.loads(state.read_text())["result"]["payload"][
                    "windows"
                ]
            except (ValueError, KeyError, TypeError):
                self.last_windows = None
            return result, log.read_text().splitlines() if log.exists() else []

    def test_exact_bundle_match_and_stable_order(self):
        """Bundle IDs match literally and the first window has the lowest ID."""
        result, actions = self.run_focus(
            [
                {"id": "ow_wrong", "windowId": 1, "app": {"bundleId": "orgXalacritty"}},
                {
                    "id": "ow_second",
                    "windowId": 20,
                    "app": {"bundleId": "org.alacritty"},
                },
                {
                    "id": "ow_first",
                    "windowId": 10,
                    "app": {"bundleId": "org.alacritty"},
                },
            ],
            "org.alacritty",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(actions, ["navigate:ow_first"])

    def test_cycles_and_wraps(self):
        """Repeated triggers cycle matching windows in stable ID order."""
        for focused, target in ((10, "ow_second"), (20, "ow_first")):
            with self.subTest(focused=focused):
                result, actions = self.run_focus(
                    [
                        {
                            "id": name,
                            "windowId": number,
                            "app": {"bundleId": "org.alacritty"},
                            "isFocused": number == focused,
                        }
                        for name, number in (("ow_second", 20), ("ow_first", 10))
                    ],
                    "org.alacritty",
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(actions, [f"navigate:{target}"])

    def test_navigates_invisible_windows_on_other_workspaces(self):
        """Off-workspace windows remain eligible for app navigation."""
        result, actions = self.run_focus(
            [
                {
                    "id": "ow_other_space",
                    "windowId": 3,
                    "app": {"bundleId": "org.mozilla.firefox"},
                    "isVisible": False,
                }
            ],
            "org.mozilla.firefox",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(actions, ["navigate:ow_other_space"])

    def test_parked_scratchpad_is_excluded(self):
        """Application cycling skips the parked overlay and keeps normal windows."""
        result, actions = self.run_focus(
            [
                {
                    "id": "ow_overlay",
                    "windowId": 1,
                    "app": {"bundleId": "org.alacritty"},
                    "isScratchpad": True,
                    "hiddenReason": "scratchpad",
                },
                {"id": "ow_main", "windowId": 2, "app": {"bundleId": "org.alacritty"}},
            ],
            "org.alacritty",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(actions, ["navigate:ow_main"])

    def overlay(self, **overrides):
        """Describe the owned revealed scratchpad above the tiled workspace."""
        return {
            "id": "ow_overlay",
            "windowId": 90,
            "app": {"bundleId": "org.alacritty"},
            "title": "code/overlay",
            "workspace": {"rawName": "1"},
            "isScratchpad": True,
            "scratchpadIndex": 1,
            "isVisible": True,
            **overrides,
        }

    def test_app_focus_parks_the_overlay_before_navigating(self):
        """Leaving the overlay for Slack removes it from later tiled navigation."""
        result, actions = self.run_focus(
            [
                self.overlay(isFocused=True),
                {
                    "id": "ow_slack",
                    "windowId": 2,
                    "app": {"bundleId": "com.tinyspeck.slackmacgap"},
                },
            ],
            "com.tinyspeck.slackmacgap",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(actions, ["park:1", "navigate:ow_slack"])
        self.assertEqual(self.last_windows[0]["hiddenReason"], "scratchpad")
        self.assertFalse(self.last_windows[0]["isVisible"])

    def test_unfocused_visible_overlay_is_also_parked(self):
        """An overlay left above tiles by mouse focus is dismissed on app selection."""
        result, actions = self.run_focus(
            [
                self.overlay(isFocused=False),
                {
                    "id": "ow_slack",
                    "windowId": 2,
                    "app": {"bundleId": "com.tinyspeck.slackmacgap"},
                },
            ],
            "com.tinyspeck.slackmacgap",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(actions, ["park:1", "navigate:ow_slack"])

    def test_already_parked_overlay_is_not_revealed(self):
        """Selecting an app cannot toggle an already parked overlay back on screen."""
        result, actions = self.run_focus(
            [
                self.overlay(isVisible=False, hiddenReason="scratchpad"),
                {
                    "id": "ow_slack",
                    "windowId": 2,
                    "app": {"bundleId": "com.tinyspeck.slackmacgap"},
                },
            ],
            "com.tinyspeck.slackmacgap",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(actions, ["navigate:ow_slack"])

    def test_native_app_launch_also_leaves_the_overlay(self):
        """Launching an app dismisses the overlay without creating another terminal."""
        result, actions = self.run_focus([self.overlay()], "us.zoom.xos")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(actions, ["park:1", "open:-b", "open:us.zoom.xos"])

    def test_selecting_the_overlay_keeps_it_visible(self):
        """Explicit Alacritty cycling to the overlay must not park its destination."""
        result, actions = self.run_focus([self.overlay()], "org.alacritty")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(actions, ["navigate:ow_overlay"])
        self.assertTrue(self.last_windows[0]["isVisible"])

    def test_failed_parking_cancels_app_navigation(self):
        """Parking failures cannot leave navigation apparently successful above an overlay."""
        result, actions = self.run_focus(
            [
                self.overlay(),
                {
                    "id": "ow_slack",
                    "windowId": 2,
                    "app": {"bundleId": "com.tinyspeck.slackmacgap"},
                },
            ],
            "com.tinyspeck.slackmacgap",
            park_status=1,
        )
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(actions, ["park:1"])
        self.assertTrue(self.last_windows[0]["isVisible"])

    def test_missing_window_activates_app_natively(self):
        """Apps without managed windows can still be activated or launched."""
        result, actions = self.run_focus([], "us.zoom.xos")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(actions, ["open:-b", "open:us.zoom.xos"])

    def test_query_failure_does_not_activate_an_app(self):
        """IPC failures propagate without masking the error with activation."""
        result, actions = self.run_focus([], "org.alacritty", query_status=2)
        self.assertEqual(result.returncode, 2)
        self.assertEqual(actions, [])

    def test_invalid_response_does_not_activate_an_app(self):
        """Rejected, malformed, and incomplete responses cause no actions."""
        for payload in ('{"ok": false}', "{", '{"ok": true}'):
            with self.subTest(payload=payload):
                result, actions = self.run_focus([], "org.alacritty", payload=payload)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(actions, [])

    def test_action_failures_propagate(self):
        """Both navigation and native activation return their failure status."""
        result, actions = self.run_focus(
            [{"id": "ow_first", "windowId": 1, "app": {"bundleId": "org.alacritty"}}],
            "org.alacritty",
            navigate_status=1,
        )
        self.assertEqual(result.returncode, 1)
        self.assertEqual(actions, ["navigate:ow_first"])
        result, actions = self.run_focus([], "us.zoom.xos", open_status=1)
        self.assertEqual(result.returncode, 1)
        self.assertEqual(actions, ["open:-b", "open:us.zoom.xos"])

    def test_missing_argument_is_a_usage_error(self):
        """The helper requires exactly one bundle ID."""
        result, actions = self.run_focus([])
        self.assertEqual(result.returncode, 2)
        self.assertEqual(actions, [])


if __name__ == "__main__":
    unittest.main()
