{ lib, pkgs, ... }:

let
  omniwmctl = "${pkgs.omniwm}/bin/omniwmctl";
  settings = import ./omniwm-settings.nix;
  windowPython = pkgs.python3.withPackages (ps: [
    ps.pyobjc-framework-ApplicationServices
    ps.pyobjc-framework-Quartz
  ]);
  focusApp = pkgs.writeShellApplication {
    name = "omniwm-focus-app";
    runtimeInputs = [
      pkgs.fish
      pkgs.jq
      pkgs.omniwm
      terminal
    ];
    text = ''
      exec fish --no-config ${./scripts/focus-app.fish} "$@"
    '';
  };
  terminal = pkgs.writeShellApplication {
    name = "omniwm-terminal";
    runtimeInputs = [
      pkgs.python3
      pkgs.alacritty
      pkgs.omniwm
      pkgs.tmux
    ];
    text = ''
      export OMNIWM_ALACRITTY="${pkgs.alacritty}/Applications/Alacritty.app/Contents/MacOS/alacritty"
      exec python3 ${./scripts/terminal.py} "$@"
    '';
  };
  windowAction = pkgs.writeShellApplication {
    name = "omniwm-window";
    runtimeInputs = [
      windowPython
      pkgs.omniwm
    ];
    text = ''
      export OMNIWM_RESIZE_STEP="${toString settings.niri.resizeStepPercent}"
      export OMNIWM_WIDTH_PRESETS='${builtins.toJSON settings.niri.containerPrimarySpanPresets}'
      exec python3 ${./scripts/window-action.py} "$@"
    '';
  };
in
{
  services.skhd = {
    enable = true;
    skhdConfig = ''
      ralt - h : ${lib.getExe windowAction} focus left
      ralt - j : ${lib.getExe windowAction} focus down
      ralt - k : ${lib.getExe windowAction} focus up
      ralt - l : ${lib.getExe windowAction} focus right

      ctrl + ralt - h : ${lib.getExe windowAction} move left
      ctrl + ralt - l : ${lib.getExe windowAction} move right

      ralt - 0x2B : ${lib.getExe windowAction} merge
      ralt - 0x2F : ${lib.getExe windowAction} split
      ralt - w : ${lib.getExe windowAction} toggle-tabs
      ralt - tab : ${lib.getExe windowAction} cycle-tabs forward
      ralt + shift - tab : ${lib.getExe windowAction} cycle-tabs backward

      ralt - 1 : ${omniwmctl} command switch-workspace anywhere 1
      ralt - 2 : ${omniwmctl} command switch-workspace anywhere 2
      ralt + shift - 1 : ${lib.getExe windowAction} send-workspace 1
      ralt + shift - 2 : ${lib.getExe windowAction} send-workspace 2

      ralt - s : ${lib.getExe windowAction} focus-monitor
      ralt + shift - s : ${lib.getExe windowAction} send-monitor

      ralt - v : ${omniwmctl} command toggle-focused-window-floating
      ralt + shift - v : ${lib.getExe windowAction} switch-layer
      ralt - c : ${lib.getExe windowAction} center
      ralt - f : ${lib.getExe windowAction} maximize

      ralt - 0x1B : ${lib.getExe windowAction} resize horizontal shrink
      ralt - 0x18 : ${lib.getExe windowAction} resize horizontal grow
      ralt + shift - 0x1B : ${lib.getExe windowAction} resize vertical shrink
      ralt + shift - 0x18 : ${lib.getExe windowAction} resize vertical grow
      ralt - r : ${lib.getExe windowAction} cycle-width

      ralt - a : ${lib.getExe focusApp} com.t3tools.t3code
      ralt - m : ${lib.getExe focusApp} com.tinyspeck.slackmacgap
      ralt - z : ${lib.getExe focusApp} us.zoom.xos
      ralt + shift - m : ${lib.getExe focusApp} org.whispersystems.signal-desktop
      ralt - b : ${lib.getExe focusApp} org.mozilla.firefox
      ralt - 0x29 : ${lib.getExe focusApp} org.mozilla.firefox
      ralt - u : ${lib.getExe focusApp} org.alacritty

      ralt - t : ${lib.getExe terminal} main
      ralt - o : ${lib.getExe terminal} overlay
      ralt - return : ${pkgs.alacritty}/Applications/Alacritty.app/Contents/MacOS/alacritty
    '';
  };

  home-manager.users."thomas.peiselt".programs.omniwm = {
    enable = true;
    launchd.enable = true;
    inherit settings;
  };
}
