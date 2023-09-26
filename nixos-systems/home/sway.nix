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
          "${m}+Shift+s" = j
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
      # bars = [
      #   {
      #     position = "top";
      #     # mode = "hide";
      #     # extraConfig = ''
      #     #   modifier "Mod4"
      #     # '';
      #   }
      # ];
    };
  };
}

