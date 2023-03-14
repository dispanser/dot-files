{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "VictorMono Nerd Font";
          style = "Medium";
        };
        bold = {
          family = "VictorMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "VictorMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "VictorMono Nerd Font";
          style = "Bold Italic";
        };
        size = 15.0;
      };
      key_bindings = [
        { key = "B"; mods = "Alt"; chars = "\\x1bb"; }
        { key = "F"; mods = "Alt"; chars = "\\x1bf"; }
        { key = "Period"; mods = "Alt"; chars = "\\x1b."; }
        { key = "Period"; mods = "Alt|Shift"; chars = "\\x1b>"; }
      ];
    };
  };
}
