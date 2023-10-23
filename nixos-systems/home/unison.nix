{ config, pkgs, ... }:

{
  services.unison = {
    enable = true;
    pairs = {
      test_sync = {
        roots = [
          "/home/pi/projects/personal/documents/"
          "ssh://tiny/home/data/sync"
        ];
      };
    };
  };
}
