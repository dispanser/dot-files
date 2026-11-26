"""Evaluate the default Darwin window-manager configuration without activating it.

Run from the repository root:
    python3 -m unittest discover -s nixos-systems/nix-darwin/tests
"""

import json
import shlex
import subprocess
import tomllib
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FLAKE = f"path:{ROOT}?dir=nixos-systems/nix-darwin"
SNAPSHOT = r"""
configurations:
let
  c = configurations.ord.config;
  home = c.home-manager.users."thomas.peiselt";
in {
  outputs = builtins.attrNames configurations;
  yabai = c.services.yabai.enable;
  scriptingAddition = c.services.yabai.enableScriptingAddition;
  yabaiAgent = c.launchd.user.agents ? yabai;
  systemPackages = map (p: p.pname or p.name) c.environment.systemPackages;
  sudo = c.security.sudo.extraConfig;
  darwinScripts = builtins.attrNames (builtins.readDir home.home.file."bin/darwin".source);
  skhd = c.services.skhd.enable;
  skhdConfig = c.services.skhd.skhdConfig;
  omniwm = home.programs.omniwm.enable;
  omniwmAgent = home.launchd.agents.omniwm.enable or false;
  omniwmProgram = home.launchd.agents.omniwm.config.Program or null;
  omniwmCli = "${home.programs.omniwm.package}/bin/omniwmctl";
  settings = home.programs.omniwm.settings;
  settingsManaged = home.xdg.configFile ? "omniwm/settings.toml";
  shell = c.users.users."thomas.peiselt".shell.pname;
  terminalPackages = map (p: p.pname) (builtins.filter
    (p: builtins.elem (p.pname or "") [ "alacritty" "tmux" ])
    c.environment.systemPackages);
  tmux = home.programs.tmux.extraConfig;
}
"""


class WindowManagerTests(unittest.TestCase):
    """Protect the default OmniWM services, shortcuts, and terminal environment."""

    @classmethod
    def setUpClass(cls):
        """Evaluate real module options using the locked flake inputs."""
        result = subprocess.run(
            [
                "nix",
                "eval",
                "--offline",
                "--no-write-lock-file",
                "--json",
                f"{FLAKE}#darwinConfigurations",
                "--apply",
                SNAPSHOT,
            ],
            check=False,
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=180,
        )
        if result.returncode:
            raise RuntimeError(result.stderr)
        cls.config = json.loads(result.stdout)

    def test_default_output_has_no_separate_omniwm_target(self):
        """The standard Mac target provides the complete window-manager setup."""
        self.assertIn("ord", self.config["outputs"])
        self.assertNotIn("ord-omniwm", self.config["outputs"])

    def test_ord_runs_only_omniwm(self):
        """The default configuration starts OmniWM without yabai or its addition."""
        self.assertFalse(self.config["yabai"])
        self.assertFalse(self.config["scriptingAddition"])
        self.assertFalse(self.config["yabaiAgent"])
        self.assertNotIn("yabai", self.config["systemPackages"])
        self.assertNotIn("yabai", self.config["sudo"])
        self.assertTrue(self.config["omniwm"])
        self.assertTrue(self.config["omniwmAgent"])
        self.assertTrue(
            self.config["omniwmProgram"].endswith(
                "/Applications/OmniWM.app/Contents/MacOS/OmniWM"
            )
        )

    def test_legacy_helpers_are_removed(self):
        """Home Manager no longer deploys obsolete yabai helpers or their tests."""
        self.assertFalse(
            any(name.startswith(",y_") for name in self.config["darwinScripts"])
        )
        self.assertFalse((ROOT / "darwin-scripts/tests/test_y_focus.py").exists())

    def test_yabai_configuration_is_removed(self):
        """Window-manager modules contain no dormant yabai configuration."""
        for name in ("darwin.nix", "omniwm.nix"):
            with self.subTest(module=name):
                source = ROOT / "nixos-systems/nix-darwin" / name
                self.assertNotIn("yabai", source.read_text())

    def test_skhd_is_the_only_hotkey_owner(self):
        """OmniWM cannot register competing global shortcuts."""
        self.assertTrue(self.config["skhd"])
        settings = self.config["settings"]
        self.assertFalse(settings["general"]["hotkeysEnabled"])
        self.assertEqual(settings["general"]["systemHyperTrigger"], "None")
        self.assertEqual(settings["hotkeys"], [])

    def test_no_yabai_bindings(self):
        """All active shortcuts use the supported helpers or pinned applications."""
        bindings = self.config["skhdConfig"]
        self.assertNotIn("yabai", bindings)
        self.assertNotIn("yabars", bindings)
        self.assertNotIn(",y_", bindings)
        self.assertIn("ralt - return", bindings)
        self.assertIn("/Applications/Alacritty.app/Contents/MacOS/alacritty", bindings)

    def bindings(self):
        """Parse the default shortcuts and reject duplicate chords."""
        bindings = {}
        for line in self.config["skhdConfig"].splitlines():
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            chord, separator, command = line.partition(" : ")
            self.assertTrue(separator, line)
            self.assertNotIn(chord.strip(), bindings)
            bindings[chord.strip()] = shlex.split(command)
        return bindings

    def test_navigation_bindings(self):
        """Shortcuts invoke the pinned CLI with niri-aligned actions."""
        bindings = self.bindings()
        expected = {
            "ralt - 1": "switch-workspace anywhere 1",
            "ralt - 2": "switch-workspace anywhere 2",
            "ralt - v": "toggle-focused-window-floating",
        }
        for chord, action in expected.items():
            with self.subTest(chord=chord):
                self.assertIn(chord, bindings)
                self.assertEqual(
                    bindings[chord],
                    [self.config["omniwmCli"], "command", *action.split()],
                )

    def test_workspace_send_bindings(self):
        """Shifted workspace keys send the actual foreground window."""
        bindings = self.bindings()
        for workspace in ("1", "2"):
            with self.subTest(workspace=workspace):
                command = bindings[f"ralt + shift - {workspace}"]
                self.assertTrue(command[0].endswith("/bin/omniwm-window"))
                self.assertEqual(command[1:], ["send-workspace", workspace])

    def test_monitor_focus_and_send_bindings(self):
        """Mod-S changes screens and Mod-Shift-S sends a window through guarded helpers."""
        bindings = self.bindings()
        for chord, action in (
            ("ralt - s", "focus-monitor"),
            ("ralt + shift - s", "send-monitor"),
        ):
            with self.subTest(chord=chord):
                command = bindings[chord]
                self.assertTrue(command[0].endswith("/bin/omniwm-window"))
                self.assertEqual(command[1:], [action])

    def test_spotlight_binding(self):
        """Mod-X opens the launcher through OmniWM's application palette."""
        command = self.bindings()["ralt - x"]
        self.assertTrue(command[0].endswith("/bin/omniwmctl"))
        self.assertEqual(
            command[1:], ["command", "open-command-palette", "applications"]
        )

    def test_restored_non_window_manager_bindings(self):
        """Text expansion, sleep, and the ISO key return from the yabai era."""
        bindings = self.bindings()
        restored = {
            "ralt - e": ["skhd", "-t", "thomas.peiselt@coralogix.com"],
            "ralt + cmd - s": ["pmset", "sleepnow"],
            "0x0A": ["skhd", "-t", "`"],
            "shift - 0x0A": ["skhd", "-t", "~"],
        }
        for chord, tail in restored.items():
            with self.subTest(chord=chord):
                command = bindings[chord]
                if chord == "ralt + cmd - s":
                    self.assertEqual(command, tail)
                else:
                    self.assertTrue(command[0].endswith("/bin/skhd"))
                    self.assertEqual(command[1:], tail[1:])

    def test_native_space_navigation_bindings(self):
        """Bracket chords route to the helper's synthesized hotkey."""
        bindings = self.bindings()
        for chord, direction in (("ralt - 0x21", "left"), ("ralt - 0x1E", "right")):
            with self.subTest(chord=chord):
                command = bindings[chord]
                self.assertTrue(command[0].endswith("/bin/omniwm-window"))
                self.assertEqual(command[1:], ["space", direction])

    def test_floating_move_bindings(self):
        """Ctrl-Mod-hjkl nudge floating windows in all four directions."""
        bindings = self.bindings()
        for chord, direction in (
            ("ctrl + ralt - h", "left"),
            ("ctrl + ralt - j", "down"),
            ("ctrl + ralt - k", "up"),
            ("ctrl + ralt - l", "right"),
        ):
            with self.subTest(chord=chord):
                command = bindings[chord]
                self.assertTrue(command[0].endswith("/bin/omniwm-window"))
                self.assertEqual(command[1:], ["move", direction])

    def test_maximized_movement_and_resize_bindings(self):
        """Ctrl-Shift chords align moving edges with the screen border."""
        bindings = self.bindings()
        expected = {
            "shift + ctrl + ralt - h": ["move-max", "left"],
            "shift + ctrl + ralt - j": ["move-max", "down"],
            "shift + ctrl + ralt - k": ["move-max", "up"],
            "shift + ctrl + ralt - l": ["move-max", "right"],
        }
        for chord, tail in expected.items():
            with self.subTest(chord=chord):
                command = bindings[chord]
                self.assertTrue(command[0].endswith("/bin/omniwm-window"))
                self.assertEqual(command[1:], tail)
        for removed in (
            "ralt + cmd + shift - h",
            "ralt + cmd + shift - l",
            "ralt + cmd + shift - k",
            "ralt + cmd + shift - j",
        ):
            with self.subTest(removed=removed):
                self.assertNotIn(removed, bindings)

    def test_code_fence_binding_types_one_triple_backtick(self):
        """Both fence keys type exactly one set of three backticks."""
        for chord in ("ralt - 0x32", "ralt - 0x0A"):
            with self.subTest(chord=chord):
                tokens = self.bindings()[chord]
                self.assertEqual(len(tokens), 3)
                self.assertTrue(tokens[0].endswith("/bin/skhd"))
                self.assertEqual(tokens[1:], ["-t", "```"])

    def test_layer_aware_navigation_bindings(self):
        """Focus and geometry shortcuts select the focused window's layer."""
        bindings = self.bindings()
        expected = {
            "ralt - h": ["focus", "left"],
            "ralt - j": ["focus", "down"],
            "ralt - k": ["focus", "up"],
            "ralt - l": ["focus", "right"],
            "ralt - c": ["center"],
            "ralt - f": ["maximize"],
            "ralt + shift - v": ["switch-layer"],
        }
        helpers = set()
        for chord, arguments in expected.items():
            with self.subTest(chord=chord):
                self.assertIn(chord, bindings)
                command = bindings[chord]
                self.assertTrue(command[0].endswith("/bin/omniwm-window"))
                self.assertEqual(command[1:], arguments)
                helpers.add(command[0])
        self.assertEqual(len(helpers), 1)

    def test_column_reordering_bindings(self):
        """Left/right moves reorder whole columns, matching niri."""
        bindings = self.bindings()
        for key, direction in (("h", "left"), ("l", "right")):
            chord = f"ctrl + ralt - {key}"
            with self.subTest(chord=chord):
                self.assertIn(chord, bindings)
                self.assertTrue(bindings[chord][0].endswith("/bin/omniwm-window"))
                self.assertEqual(bindings[chord][1:], ["move", direction])

    def test_tab_group_cycle_bindings(self):
        """Mod-Tab and Shift-Mod-Tab wrap within the current group through the helper."""
        bindings = self.bindings()
        for chord, direction in (
            ("ralt - tab", "forward"),
            ("ralt + shift - tab", "backward"),
        ):
            with self.subTest(chord=chord):
                self.assertIn(chord, bindings)
                self.assertTrue(bindings[chord][0].endswith("/bin/omniwm-window"))
                self.assertEqual(bindings[chord][1:], ["cycle-tabs", direction])

    def test_tabbed_column_binding_and_app_icons(self):
        """Mod-W toggles tabbed columns and the rail identifies hidden applications."""
        bindings = self.bindings()
        self.assertIn("ralt - w", bindings)
        self.assertTrue(bindings["ralt - w"][0].endswith("/bin/omniwm-window"))
        self.assertEqual(bindings["ralt - w"][1:], ["toggle-tabs"])
        self.assertTrue(self.config["settings"]["appearance"]["tabRailAppIcons"])

    def test_column_merge_and_split_bindings(self):
        """Comma merges and period splits through the layer-aware helper, matching niri."""
        bindings = self.bindings()
        for chord, action in (("ralt - 0x2B", "merge"), ("ralt - 0x2F", "split")):
            with self.subTest(chord=chord):
                self.assertIn(chord, bindings)
                self.assertTrue(bindings[chord][0].endswith("/bin/omniwm-window"))
                self.assertEqual(bindings[chord][1:], [action])

    def test_application_bindings(self):
        """App shortcuts use exact bundle IDs through the same focus helper."""
        bindings = self.bindings()
        expected = {
            "ralt - a": "com.t3tools.t3code",
            "ralt - m": "com.tinyspeck.slackmacgap",
            "ralt - z": "us.zoom.xos",
            "ralt + shift - m": "org.whispersystems.signal-desktop",
            "ralt - b": "org.mozilla.firefox",
            "ralt - 0x29": "org.mozilla.firefox",
            "ralt - u": "org.alacritty",
        }
        helpers = set()
        for chord, bundle in expected.items():
            with self.subTest(chord=chord):
                self.assertIn(chord, bindings)
                command = bindings[chord]
                self.assertTrue(command[0].endswith("/bin/omniwm-focus-app"))
                self.assertEqual(command[1:], [bundle])
                helpers.add(command[0])
        self.assertEqual(len(helpers), 1)

    def test_fixed_terminal_bindings(self):
        """Main and overlay shortcuts share one session-preserving helper."""
        bindings = self.bindings()
        helpers = set()
        for chord, role in (("ralt - t", "main"), ("ralt - o", "overlay")):
            with self.subTest(chord=chord):
                self.assertIn(chord, bindings)
                command = bindings[chord]
                self.assertTrue(command[0].endswith("/bin/omniwm-terminal"))
                self.assertEqual(command[1:], [role])
                helpers.add(command[0])
        self.assertEqual(len(helpers), 1)
        settings = self.config["settings"]
        self.assertEqual(settings["scratchpads"]["labels"]["1"], "overlay")
        overlay_rule = next(
            rule
            for rule in settings["appRules"]
            if rule.get("titleRegex") == "^code/overlay$"
        )
        self.assertEqual(overlay_rule["bundleId"], "org.alacritty")
        self.assertEqual(overlay_rule["layout"], "float")

    def test_width_bindings_and_niri_presets(self):
        """Resizing has step bindings on both Mod-Shift-H/J/K/L and minus/equals."""
        bindings = self.bindings()
        expected = {
            "ralt + shift - h": ["resize", "horizontal", "shrink"],
            "ralt + shift - l": ["resize", "horizontal", "grow"],
            "ralt + shift - k": ["resize", "vertical", "shrink"],
            "ralt + shift - j": ["resize", "vertical", "grow"],
            "ralt - 0x1B": ["resize", "horizontal", "shrink"],
            "ralt - 0x18": ["resize", "horizontal", "grow"],
            "ralt + shift - 0x1B": ["resize", "vertical", "shrink"],
            "ralt + shift - 0x18": ["resize", "vertical", "grow"],
            "ralt - r": ["cycle-width"],
        }
        for chord, arguments in expected.items():
            with self.subTest(chord=chord):
                self.assertIn(chord, bindings)
                self.assertTrue(bindings[chord][0].endswith("/bin/omniwm-window"))
                self.assertEqual(bindings[chord][1:], arguments)
        for removed in (
            "alt + ralt - h",
            "alt + ralt - l",
            "alt + ralt - k",
            "alt + ralt - j",
            "alt + ralt + shift - h",
            "alt + ralt + shift - l",
            "alt + ralt + shift - k",
            "alt + ralt + shift - j",
            "ralt + cmd + shift - h",
            "ralt + cmd + shift - l",
            "ralt + cmd + shift - k",
            "ralt + cmd + shift - j",
        ):
            with self.subTest(removed=removed):
                self.assertNotIn(removed, bindings)
        niri = self.config["settings"]["niri"]
        self.assertEqual(niri["containerPrimarySpanPresets"], [0.5, 0.75, 0.9])
        self.assertEqual(niri["defaultContainerPrimarySpan"], 0.5)
        self.assertEqual(niri["resizeStepPercent"], 10)

    def test_ipc_and_niri_are_configured_declaratively(self):
        """OmniWM exposes IPC and uses the scrolling layout."""
        self.assertTrue(self.config["settingsManaged"])
        general = self.config["settings"]["general"]
        self.assertTrue(general["ipcEnabled"])
        self.assertEqual(general["defaultLayoutType"], "niri")
        self.assertFalse(general["updateChecksEnabled"])
        self.assertEqual(self.config["settings"]["schemaVersion"], 4)

    def test_complete_version_four_settings(self):
        """Every required v0.7.6 table is present, even for disabled features."""
        settings = self.config["settings"]
        required = {
            "general": "hotkeysEnabled systemHyperTrigger hyperKeyModifiers "
            "defaultLayoutType preventSleepEnabled updateChecksEnabled "
            "ipcEnabled animationsEnabled",
            "focus": "followsMouse raiseOnMouseFocus lockModifier "
            "moveMouseToFocusedWindow followsWindowToMonitor "
            "crossesMonitorAtEdge moveCrossesMonitorAtEdge",
            "mouseWarp": "margin enabled constrainToArrangement",
            "routing": "mode arrangements",
            "gaps": "size fullscreenUsesOuterGaps outer",
            "niri": "visibleContainerCount infiniteLoop centerFocusedColumn "
            "alwaysCenterSingleColumn singleWindowFit",
            "dwindle": "smartSplit defaultSplitRatio splitWidthMultiplier "
            "singleWindowFit useGlobalGaps moveToRootStable",
            "borders": "enabled width color",
            "overview": "zoom backdrop windowBorders",
            "workspaceBar": "enabled showLabels showFloatingWindows windowLevel "
            "position notchMode notchActiveZoneWidth systemStatsButton "
            "deduplicateAppIcons hideEmptyWorkspaces excludedBundleIDs "
            "iconOverrides reserveLayoutSpace revealModifier "
            "revealHoldMilliseconds hideInNativeFullscreen height "
            "backgroundOpacity xOffset yOffset",
            "gestures": "scrollEnabled scrollSensitivity scrollModifierKey "
            "mouseMoveModifierKey mouseResizeModifierKey fingerCount "
            "invertDirection trackpadScrollStyle workspaceSwipeEnabled "
            "workspaceSwipeFingerCount workspaceSwipeAxis",
            "statusBar": "showWorkspaceName showAppNames useWorkspaceId",
            "hiddenBar": "enabled hiddenBundleIDs rehideIntervalSeconds",
            "clipboard": "historyEnabled maxItems maxItemBytes maxTotalBytes",
            "quakeTerminal": "enabled position widthPercent heightPercent "
            "animationDuration autoHide backgroundEffect",
            "scratchpads": "labels",
            "appearance": "mode",
        }
        for table, keys in required.items():
            with self.subTest(table=table):
                self.assertTrue(set(keys.split()) <= settings[table].keys())
        for key in (
            "hotkeys",
            "workspaces",
            "appRules",
            "monitorBarOverrides",
            "monitorOrientationOverrides",
            "monitorNiriOverrides",
            "monitorDwindleOverrides",
            "monitorGapOverrides",
        ):
            with self.subTest(array=key):
                self.assertIsInstance(settings[key], list)
        self.assertTrue(settings["workspaces"])
        firefox = next(
            rule
            for rule in settings["appRules"]
            if rule["bundleId"] == "org.mozilla.firefox"
        )
        self.assertGreater(firefox["minWidth"], 0)
        self.assertFalse(settings["clipboard"]["historyEnabled"])
        self.assertFalse(settings["quakeTerminal"]["enabled"])
        self.assertFalse(settings["hiddenBar"]["enabled"])

    def test_generated_toml_matches_settings(self):
        """Home Manager serializes the complete settings without losing tables."""
        result = subprocess.run(
            [
                "nix",
                "build",
                "--no-write-lock-file",
                "--no-link",
                "--print-out-paths",
                (
                    f"{FLAKE}#darwinConfigurations.ord.config.home-manager."
                    'users."thomas.peiselt".xdg.configFile."omniwm/settings.toml".source'
                ),
            ],
            check=False,
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=180,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        generated = tomllib.loads(Path(result.stdout.strip()).read_text())
        self.assertEqual(generated, self.config["settings"])

    def test_terminal_environment_is_preserved(self):
        """The default setup keeps Fish, both terminal packages, and the tmux startup fix."""
        self.assertEqual(self.config["shell"], "fish")
        self.assertCountEqual(self.config["terminalPackages"], ["alacritty", "tmux"])
        self.assertIn('set -g default-command ""', self.config["tmux"])


if __name__ == "__main__":
    unittest.main()
