{ pkgs, ... }:

{
  languages.haskell = {
    enable = true;
    lsp.enable = true;
    stack.enable = true;
  };

  # System libraries required by xmonad and X11 stack dependencies
  packages = with pkgs; [
    libx11
    libxrandr
    libxext
    libxft
    libxcb
    libxdmcp
    expat
    fontconfig
    libxscrnsaver
    libxinerama
    pkg-config
  ];
}
