{ tsg, ... }:

{
  nixpkgs.overlays = [
    (import ./llm.nix)

    (final: prev: {
      touchscreen-gestures = tsg.packages.${prev.system}.default;
    })

    # # Overlay 1: Use `self` and `super` to express
    # # the inheritance relationship
    # (self: super: {
    #   google-chrome = super.google-chrome.override {
    #     commandLineArgs =
    #       "--proxy-server='https=127.0.0.1:3128;http=127.0.0.1:3128'";
    #   };
    # })

    # # Overlay 2: Use `final` and `prev` to express
    # # the relationship between the new and the old
    # (final: prev: {
    #   steam = prev.steam.override {
    #     extraPkgs = pkgs: with pkgs; [
    #       keyutils
    #       libkrb5
    #       libpng
    #       libpulseaudio
    #       libvorbis
    #       stdenv.cc.cc.lib
    #       xorg.libXcursor
    #       xorg.libXi
    #       xorg.libXinerama
    #       xorg.libXScrnSaver
    #     ];
    #     extraProfile = "export GDK_SCALE=2";
    #   };
    # })

  ];
}
