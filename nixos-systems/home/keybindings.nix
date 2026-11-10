# Emacs/readline-style editing keys for all macOS AppKit text fields.
# The selectors are the Cocoa text system's; see
# https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/TextDefaultsBindings/TextDefaultsBindings.html
{ lib, pkgs, ... }:

{
  home.file."Library/KeyBindings/DefaultKeyBinding.dict" = {
    enable = pkgs.stdenv.hostPlatform.isDarwin;
    text = ''
      /* Readline/emacs-style editing for all AppKit text fields (Mail, Notes,
       * Safari, Chrome, most native apps). Applies only to apps using the macOS
       * text system; Firefox and apps with custom editors (VS Code, JetBrains)
       * ignore it.
       *
       * Already built in without this file:
       *   C-a/C-e  line start/end        C-f/b/n/p  char + line motion
       *   C-d/C-h  delete char fwd/back  C-k        kill to end of line
       *   C-y      yank (paste last deletion)
       *   C-t      transpose chars       C-v        page down
       *   C-o      open line
       */
      {
          /* word motion */
          "~f"      = "moveWordForward:";     /* M-f */
          "~b"      = "moveWordBackward:";    /* M-b */

          /* word killing */
          "~d"      = "deleteWordForward:";   /* M-d */
          "~\010"   = "deleteWordBackward:";  /* M-backspace */
          "~\177"   = "deleteWordBackward:";  /* M-delete */
          "^u"      = "deleteToBeginningOfLine:"; /* C-u, kill to line start */
          "^w"      = "deleteWordBackward:";  /* C-w, unix-word-rubout */

          /* undo */
          "^/"      = "undo:";                /* C-/ */
          "^_"      = "undo:";                /* C-_ */

          /* word completion popup (suggests words from document + system lexicon) */
          "~/"      = "complete:";            /* M-/ */
      }
    '';
  };
}
