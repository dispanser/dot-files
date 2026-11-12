"""Test pane startup on an isolated tmux server.

Run with: python3 -m unittest discover -s darwin-scripts/tests
"""

import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]


class TmuxStartupTests(unittest.TestCase):
    """Check that reloading config removes obsolete pane startup commands."""

    def test_reload_clears_obsolete_wrapper_and_starts_shell(self):
        """New panes start a shell after an obsolete wrapper is removed."""
        result = subprocess.run(
            [
                "nix-instantiate", "--eval", "--strict", "--json", "--expr",
                '(import ./nixos-systems/home/tmux.nix { pkgs = {}; })'
                '.programs.tmux.extraConfig',
            ],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=True,
            timeout=30,
        )
        config = json.loads(result.stdout)
        with tempfile.TemporaryDirectory(prefix="agent-tmux-", dir="/tmp") as directory:
            path = Path(directory)
            config_path = path / "tmux.conf"
            config_path.write_text(config)
            command = [shutil.which("tmux"), "-S", str(path / "socket")]
            env = {k: v for k, v in os.environ.items() if k not in ("TMUX", "TMUX_PANE")}

            def tmux(*args):
                """Run a command against the isolated server."""
                return subprocess.run(
                    [*command, *args], env=env, capture_output=True,
                    text=True, check=True, timeout=10,
                ).stdout.strip()

            try:
                tmux("-f", "/dev/null", "new-session", "-d", "-s", "test", "/bin/sleep 300")
                tmux("set-option", "-g", "default-shell", shutil.which("fish"))
                tmux("set-option", "-g", "default-command", str(path / "missing-wrapper"))
                tmux("source-file", str(config_path))
                self.assertEqual(tmux("show-options", "-gv", "default-command"), "")
                pane = tmux("new-window", "-d", "-P", "-F", "#{pane_id}")
                pane = tmux("split-window", "-d", "-t", pane, "-P", "-F", "#{pane_id}")
                signal = shlex.join([*command, "wait-for", "-S", "shell-ready"])
                tmux("send-keys", "-t", pane, signal, "Enter")
                tmux("wait-for", "shell-ready")
                self.assertEqual(tmux("display-message", "-p", "-t", pane, "#{pane_dead}"), "0")
            finally:
                subprocess.run([*command, "kill-server"], env=env, capture_output=True, timeout=10)
