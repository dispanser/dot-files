{ lib, pkgs, isServer, ... }:

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
      "Name .local"
    ];
    paths = [
      "projects"
      "src"
      ".password-store"
      ".mail"
    ];
    ssh_script = "${pkgs.writeShellScript "ssh_unison.sh" ''
      exec 2> /tmp/unison.err.log
      exec ${pkgs.openssh}/bin/ssh "$@"
    ''}";
  in {
    enable = lib.mkIf pkgs.stdenv.isLinux true;
    pairs = {
      tiny_sync = {
        roots = [
          "/home/pi/"
          (if isServer then 
            "/home/data/sync/home/pi/"
          else
            "ssh://tiny//home/data/sync/home/pi/")
        ];
        commandOptions = {
          ignore = ignores;
          path = paths;
          prefer = "newer";
          auto = "true";
          batch = "true";
          log = "false";
          repeat = "watch";
          sshcmd = "${ssh_script}";
          ui = "text";
        };
      };
    };
  };
}
