{ ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        cursorline = true;
        line-number = "relative";
        file-picker.hidden = false;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
      keys.normal = {
        space = {
          space = "command_palette";
          tab = "goto_last_accessed_file";
          f = {
            f = "file_picker";
            w = ":w";
            S = ":w!";
          };
          b = {
            b = "buffer_picker";
            c = ":buffer-close";
            n = "goto_next_buffer";
            p = "goto_previous_buffer";
            r = ":reload";
          };
        };
        # "C-h" =
      };
      keys.insert = {
        # not ideal: there is no timeout, but instead the pop-up appears.
        # if you just keep writing, it's immediately resolved.
        # maybe: use a rarely used character as the prefix key, lose home row
        j.k = "normal_mode";
        j.w = [ ":w" "normal_mode" ];
        j.q = ":wq";
      };
    };
  };
}
