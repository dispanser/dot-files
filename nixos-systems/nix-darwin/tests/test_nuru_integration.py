"""Evaluate the nuru integration in both platform flakes without activating anything.

Run from the repository root:
    python3 -m unittest discover -s nixos-systems/nix-darwin/tests

The Darwin flake is evaluated for real: the private nuru checkout is available
on this machine, so the overlay, the module, and the gated enablement can all
be resolved. The Linux flake references `/home/pi/...`, which only exists on
the NixOS hosts, so its wiring is checked textually here.
"""

import json
import subprocess
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
  nuruOverlay = configurations.ord.pkgs ? nuru;
  nuruPname = configurations.ord.pkgs.nuru.pname or null;
  nuruVersion = configurations.ord.pkgs.nuru.version or null;
  nuruMainProgram = configurations.ord.pkgs.nuru.meta.mainProgram or null;
  nuruOption = home ? programs.nuru;
  nuruEnable = home.programs.nuru.enable or null;
  nuruInPackages = builtins.any (p: (p.pname or "") == "nuru") home.home.packages;
}
"""


class NuruIntegrationTests(unittest.TestCase):
    """Protect the nuru overlay, module, and platform-gated enablement."""

    @classmethod
    def setUpClass(cls):
        """Evaluate real module options using the flake inputs."""
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
            timeout=300,
        )
        if result.returncode:
            raise RuntimeError(result.stderr)
        cls.config = json.loads(result.stdout)

    def test_darwin_overlay_builds_nuru(self):
        """The nuru overlay is applied on macOS and exposes the CLI package."""
        self.assertTrue(self.config["nuruOverlay"])

    def test_module_is_imported_on_darwin(self):
        """The shared home-manager module contributes its options on macOS."""
        self.assertTrue(self.config["nuruOption"])

    def test_nuru_is_disabled_without_linux(self):
        """nuru drives niri sessions, so macOS neither enables nor installs it."""
        self.assertIs(self.config["nuruEnable"], False)
        self.assertFalse(self.config["nuruInPackages"])

    def test_overlay_package_is_the_nuru_cli(self):
        """The overlay's package is the nuru command with the checkout's version."""
        result = subprocess.run(
            [
                "nix",
                "eval",
                "--offline",
                "--no-write-lock-file",
                "--json",
                f"{FLAKE}#darwinPackages.nuru.pname",
            ],
            check=False,
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=120,
        )
        if result.returncode:
            raise RuntimeError(result.stderr)
        self.assertEqual(json.loads(result.stdout), "nuru")

    def test_both_flakes_take_nuru_as_a_private_git_input(self):
        """The checkout is consumed like llm-proxy: committed tree, flake = false."""
        for flake in (
            ROOT / "nixos-systems/flake.nix",
            ROOT / "nixos-systems/nix-darwin/flake.nix",
        ):
            with self.subTest(flake=str(flake.relative_to(ROOT))):
                source = flake.read_text()
                self.assertIn("nuru", source)
                self.assertIn("flake = false", source)

    def test_linux_flake_passes_nuru_to_the_overlays_and_module(self):
        """NixOS hosts receive the overlay through overlays/default.nix and the module."""
        self.assertIn(
            "nuru = inputs.nuru", (ROOT / "nixos-systems/flake.nix").read_text()
        )
        overlays = (ROOT / "nixos-systems/overlays/default.nix").read_text()
        self.assertIn("nuru", overlays)
        shared = (ROOT / "nixos-systems/flake.nix").read_text()
        self.assertIn("./modules/nuru.nix", shared)

    def test_darwin_flake_applies_the_nuru_overlay_and_module(self):
        """The macOS flake wires the same overlay and module into its evaluation."""
        source = (ROOT / "nixos-systems/nix-darwin/flake.nix").read_text()
        self.assertIn("overlays/nuru.nix", source)
        self.assertIn("../modules/nuru.nix", source)

    def test_home_enables_nuru_only_on_linux(self):
        """Shared home configuration gates nuru on the niri platforms."""
        source = (ROOT / "nixos-systems/home/home.nix").read_text()
        self.assertIn("nuru.enable", source)
        self.assertIn("isLinux", source)

    def test_module_defers_to_the_overlay_package(self):
        """The module installs the overlay's package through an overridable option."""
        module = (ROOT / "nixos-systems/modules/nuru.nix").read_text()
        self.assertIn("programs.nuru", module)
        self.assertIn("mkPackageOption", module)
        self.assertIn("home.packages", module)

    def test_overlay_builds_the_committed_checkout(self):
        """The overlay documents the private-checkout workflow and hash upkeep."""
        overlay = (ROOT / "nixos-systems/overlays/nuru.nix").read_text()
        self.assertIn("flake = false", overlay)
        self.assertIn("cargoHash", overlay)
        self.assertIn("buildRustPackage", overlay)


if __name__ == "__main__":
    unittest.main()
