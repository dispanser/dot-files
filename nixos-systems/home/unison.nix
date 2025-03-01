{ lib, pkgs, ... }:

{
  services.unison =
    let ignores = [
      "Name *.o"
      "Name *.hi"
      "Name xmonad-x86_64-linux"
      "Name *.class"
      "Name *.jar"
      "Name .password-store/.git"
      "Name personal/diary/.git"
      "Name src/github/dispanser/dot-files"
      "Name src/github/dispanser/partition-index/.git"
      "Name target"
      "Name build"
      "Name debug"
      "Name .gradle"
      "Name .cache"
      "Name .chromium"
      "Name .stack-work"
      "Name .qute/cache"
      "Name .qute/data"
      "Name .qute/runtime"
      "Name *.log"
      "Name .direnv"
      "Name .devenv"
      "Name _internal.abi3.so"
      "Name __pycache__"
      "Name src/github/NixOS"
    ];
    paths = [
      "projects"
      "src"
      ".password-store"
    ];
  in {
    enable = lib.mkIf pkgs.stdenv.isLinux true;
    pairs = {
      tiny_sync = {
        roots = [
          "/home/pi/"
          "ssh://tiny//home/data/sync/home/pi/"
        ];
        commandOptions = {
          prefer = "newer";
          auto = "true";
          batch = "true";
          log = "false";
          repeat = "watch";
          sshcmd = "${pkgs.openssh}/bin/ssh";
          ui = "text";
          ignore = ignores;
          path = paths;
        };
      };
    };
  };
}
