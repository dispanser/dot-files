{ pkgs, lib, config, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    swaynag.enable = true;
    systemd.enable = true;
    config = rec {
      workspaceAutoBackAndForth = true;
      modifier = "Mod5";
      terminal = "alacritty";
      startup = [ 
        { command = "alacritty"; }
      ];
      output = {
        "DP-3" = {
          transform = "90";
        };
      };
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_options = "caps:escape,compose:lwin-altgr,lv3:ralt_switch,terminate:ctrl_alt_bksp";
        };
      };
      keybindings =
        let
          m = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          "${m}+s" = "focus output left";
          "${m}+Shift+s" = "move container to output left";
          "${m}+bracketright" = "workspace next";
          "${m}+bracketleft" = "workspace prev";
          "${m}+Shift+bracketright" = "move container to workspace next";
          "${m}+Shift+bracketleft" = "move container to workspace prev";
        };
      gaps = {
        smartBorders = "on";
        outer = 5;
        inner = 5;
      };
      modes = {
        "resize" = 
          let stepSize = "30";
              largeStep = "100"; 
          in {
            Escape = "mode default";
            Return = "mode default";
            h = "resize shrink width 3 ppt";
            j = "resize grow height 3 ppt";
            k = "resize shrink height 3 ppt";
            l = "resize grow width 3 ppt";
            "Shift+h" = "resize shrink width 10 ppt";
            "Shift+j" = "resize grow height 10 ppt";
            "Shift+k" = "resize shrink height 10 ppt";
            "Shift+l" = "resize grow width 10 ppt";
          };
      };
      bars = [
        {
          position = "top";
          mode = "hide";
          extraConfig = ''
            modifier "Mod4"
            tray_output primary
            font "Inconsolata Nerd Font 12.00"
            status_command ${pkgs.i3status}/bin/i3status
            swaybar_command ${pkgs.sway}/bin/swaybar
          '';
        }
      ];
    };
  };
}

