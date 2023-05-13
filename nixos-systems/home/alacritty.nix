{ pkgs, ... }:

{
  programs.alacritty = 
   let fontSize = if pkgs.stdenv.isLinux then 10.0 else 15.0;
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
         { key = "B"; mods = "Alt"; chars = "\\x1bb"; }
         { key = "F"; mods = "Alt"; chars = "\\x1bf"; }
         { key = "D"; mods = "Alt"; chars = "\\x1bd"; }
         { key = "C"; mods = "Alt"; chars = "\\x1bc"; }

         { key = "Caret"; mods = "Alt"; chars = "\\x1b0"; }
         { key = "Key0"; mods = "Alt"; chars = "\\x1b0"; }
         { key = "Key1"; mods = "Alt"; chars = "\\x1b1"; }
         { key = "Key2"; mods = "Alt"; chars = "\\x1b2"; }
         { key = "Key3"; mods = "Alt"; chars = "\\x1b3"; }
         { key = "Key4"; mods = "Alt"; chars = "\\x1b4"; }
         { key = "Key5"; mods = "Alt"; chars = "\\x1b5"; }
         { key = "Key6"; mods = "Alt"; chars = "\\x1b6"; }
         { key = "Key7"; mods = "Alt"; chars = "\\x1b7"; }
         { key = "Key8"; mods = "Alt"; chars = "\\x1b8"; }
         { key = "Key9"; mods = "Alt"; chars = "\\x1b9"; }
         { key = "Period"; mods = "Alt"; chars = "\\x1b."; }
         { key = "Period"; mods = "Alt|Shift"; chars = "\\x1b>"; }
       ];
     };
   };
}
