{ pkgs, lib,... }:

{
  # override: disable on low-memory systems b/c it just freaks out all
  # my qute tabs. OTOH, maybe that's a good thing.
  services.earlyoom.enable = lib.mkForce false;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    priority = 100;
    # compression ratio ~ 8x, so this only occupies small fraction of RAM
    memoryPercent = 99;
  };
}
