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
    font.name = "Victor Mono";
    font.package = pkgs.victor-mono;
    extraConfig = ''
      # BEGIN_KITTY_THEME
      # Solarized Dark
      include current-theme.conf
      # END_KITTY_THEME
    '';
  };
}
