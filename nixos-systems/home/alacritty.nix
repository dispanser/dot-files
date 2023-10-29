{ pkgs, ... }:

{
  programs.alacritty = 
   let fontSize = if pkgs.stdenv.isLinux then 8.0 else 15.0;
   in {
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
         size = fontSize;
       };
       key_bindings = [
         # not a mistake - mapping the key multiple times triggers the action
         # more than onc: https://github.com/alacritty/alacritty/issues/5405
         { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }
         { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }
         { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }
         { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }

         # 'shift' doesn't work, unfortunately
         { key = "Equals"; mods = "Control|Alt"; action = "IncreaseFontSize"; }
         { key = "Equals"; mods = "Control|Alt"; action = "IncreaseFontSize"; }

         { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
         { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
         { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
         { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
         { key = "Minus"; mods = "Control|Alt"; action = "DecreaseFontSize"; }
         { key = "Minus"; mods = "Control|Alt"; action = "DecreaseFontSize"; }
       ];
     };
   };
}
