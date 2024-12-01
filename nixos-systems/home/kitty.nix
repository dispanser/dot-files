{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    # theme  = "Solarized Dark Higher Contrast";
    theme  = "Solarized Dark - Patched";
    settings = {
      allow_remote_control = true;
      cursor_shape = "underline";
      adjust_column_width	= "100%";

      # darwin-specific options
      macos_option_as_alt = "yes";
      macos_quit_when_last_window_closed = "yes";
      hide_window_decorations = "yes"; # darwin only because xmonad doesn't care
    };
    keybindings = {
      "ctrl+minus"             = "change_font_size all -2.0";
      "ctrl+equal"             = "change_font_size all +2.0";
      "ctrl+shift+equal"       = "no_op";
      "ctrl+shift+plus"        = "no_op";
      "ctrl+shift+kp_add"      = "no_op";
      "ctrl+shift+minus"       = "no_op";
      "ctrl+shift+kp_subtract" = "no_op";
    };
    font = {
      # doesn't seem to work - font size is accepted, but changing the font
      # itself is not change
      name = "VictorMono Nerd Font";
      package = pkgs.nerd-fonts.victor-mono;
      size = 20;
    };
    extraConfig = ''
      # BEGIN_KITTY_THEME
      # Solarized Dark
      # include current-theme.conf
      # END_KITTY_THEME
    '';
  };
}
