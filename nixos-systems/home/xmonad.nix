{ pkgs, ... }:

{
  # I think this is useless - we either manage the xmonad.hs and lib inside
  # nix home manager, which _probably_ means that we can't just experiment
  # with xmonad.hs quickly, or we don't :)
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = "../../xmonad/xmonad.hs";
    libFiles = {
      "PiMonad/Workspaces.hs" = "../../xmonad/lib/Workspaces.hs";
      "PiMonad/Scratches.hs" = "../../xmonad/lib/Scratches.hs";
    };
  };
}
