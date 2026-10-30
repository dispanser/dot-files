"""Test the Fish focus helper with a mocked yabai; no desktop state is changed.

Run with: python3 -m unittest discover -s darwin-scripts/tests
"""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / ",y_focus.fish"
AGENT_PATTERN = r"^T3 Code( \(Beta\))?$"


class FocusTests(unittest.TestCase):
    """Exercise exact matching, regex matching, and window cycling."""

    def run_focus(self, windows, *args):
        """Run the helper against a fixture and return its result and focus calls."""
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            mock = root / "yabai"
            mock.write_text(
                '#!/bin/sh\n'
                'case "$*" in\n'
                '  "-m query --windows") printf "%s\\n" "$MOCK_WINDOWS" ;;\n'
                '  "-m window --focus "*) printf "%s\\n" "$4" >> "$MOCK_LOG" ;;\n'
                '  *) exit 2 ;;\n'
                'esac\n'
            )
            mock.chmod(0o755)
            log = root / "focus.log"
            result = subprocess.run(
                ["fish", "--no-config", str(SCRIPT), *args],
                env={
                    **os.environ,
                    "PATH": directory + os.pathsep + os.environ["PATH"],
                    "MOCK_WINDOWS": json.dumps(windows),
                    "MOCK_LOG": str(log),
                },
                capture_output=True,
                text=True,
                timeout=10,
            )
            focused = log.read_text().splitlines() if log.exists() else []
            return result, focused

    def test_exact_match_preserves_literal_punctuation(self):
        """Existing shortcuts match dots literally and select the first window."""
        result, focused = self.run_focus(
            [{"id": 1, "app": "zoomXus"}, {"id": 2, "app": "zoom.us"}],
            "zoom.us",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(focused, ["2"])

    def test_exact_match_handles_quotes(self):
        """App names are passed as data to jq."""
        result, focused = self.run_focus(
            [{"id": 1, "app": 'An "App"'}], 'An "App"'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(focused, ["1"])

    def test_agent_regex_matches_stable_and_beta(self):
        """The agent shortcut works across the beta-to-stable rename."""
        for app in ("T3 Code", "T3 Code (Beta)"):
            with self.subTest(app=app):
                result, focused = self.run_focus(
                    [
                        {"id": 1, "app": "Other T3 Code"},
                        {"id": 2, "app": "T3 Code Tools"},
                        {"id": 3, "app": "T3 Code (Beta) Tools"},
                        {"id": 4, "app": app},
                    ],
                    "--regex",
                    AGENT_PATTERN,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(focused, ["4"])

    def test_cycles_and_wraps_in_both_matching_modes(self):
        """Repeated invocations advance through matching windows and wrap."""
        for args in (("Slack",), ("--regex", "^Slack$")):
            for focused_id, expected in ((1, "2"), (2, "1")):
                with self.subTest(args=args, focused_id=focused_id):
                    result, focused = self.run_focus(
                        [
                            {"id": i, "app": "Slack", "has-focus": i == focused_id}
                            for i in (1, 2)
                        ],
                        *args,
                    )
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(focused, [expected])

    def test_no_match_is_a_noop(self):
        """An absent application does not cause a focus command."""
        for args in (("T3 Code",), ("--regex", AGENT_PATTERN)):
            with self.subTest(args=args):
                result, focused = self.run_focus(
                    [{"id": 1, "app": "Slack"}, {"id": 2, "app": "T3 Code Tools"}],
                    *args,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(focused, [])

    def test_invalid_regex_fails_without_focusing(self):
        """Malformed patterns are reported as errors."""
        result, focused = self.run_focus(
            [{"id": 1, "app": "Slack"}], "--regex", "["
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(focused, [])

    def test_missing_argument_fails(self):
        """A missing app matcher is a usage error."""
        result, focused = self.run_focus([])
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(focused, [])


if __name__ == "__main__":
    unittest.main()
