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
        size = 7.0;
      };
    };
  };
}
