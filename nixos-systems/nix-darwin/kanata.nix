# from https://github.com/nix-darwin/nix-darwin/pull/1561
{ lib, pkgs, ... }:
let
  kbdCfg = builtins.toFile "kanata.kbd" ''
    ;; first attempt: only map rows that also exist on the piantor

    (defcfg
      sequence-timeout 50
      sequence-input-mode hidden-delay-type
      linux-dev-names-include (
        "Darfon Thinkpad X12 Detachable Gen 1 Folio case -1"
        "Darfon ThinkPad X12 Detachable Gen 2 Folio Keyboard"
        "Chicony ThinkPad X1 Tablet Thin Keyboard Gen 3"
        "Lenovo ThinkPad Compact USB Keyboard with TrackPoint"
      )
      macos-dev-names-include (
        "Apple Internal Keyboard / Trackpad"
        "ThinkPad Compact USB Keyboard with TrackPoint"
      )
      process-unmapped-keys yes
    )

    (defsrc
      ;; grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      caps a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft IntlBackslash z    x    c    v    b    n    m    ,    .    /    rsft
      lctl lmet lalt           spc            ralt rctl
    )

    ;; @f
    (defalias escnr (tap-hold 200 200 esc
      (layer-while-held numbers)))

    (deflayer main
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      @escnr  a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft grv z    x    c    v    b    n    m    ,    .    /    rsft
      lctl lmet lalt           spc            ralt rctl
    )

    ;; from https://github.com/jtroo/kanata/discussions/499#discussioncomment-6513739
    (deffakekeys
      esca esc
    )
    (defseq esca (k l))
    (defseq esca (l k))

    (deflayer numbers
      grv  q    3    2    1    +    y    S-9    S-0    [    ]    [    ]    \
      tab  7    6    5    4    -    left down up   rght \    '    ret
      lsft grv z    0    9    8    =    S-[  S-]    ,    .    /    rsft
      lctl lmet lalt           spc            ralt rctl
    )

    (defalias
      ;; toggle layer aliases
      num (layer-toggle numbers)
      ;; ( S-9
      ;; ) S-0
      { S-[
      } S-]
    )
  '';
  parentAppDir = "/Applications/.Nix-Karabiner";
in
{
  environment.systemPackages = [ pkgs.kanata ];

  system.activationScripts.preActivation.text = ''
    rm -rf ${parentAppDir}
    mkdir -p ${parentAppDir}
    # Kernel extensions must reside inside of /Applications, they cannot be symlinks
    cp -r ${pkgs.karabiner-elements.driver}/Applications/.Karabiner-VirtualHIDDevice-Manager.app ${parentAppDir}
  '';

  # activate extension
  launchd.user.agents.activate_karabiner_system_ext = {
    serviceConfig.ProgramArguments = [
      "${parentAppDir}/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager"
      "activate"
    ];
    serviceConfig.RunAtLoad = true;
  };

  launchd.daemons.Karabiner-DriverKit-VirtualHIDDevice-Daemon = {
    command = "\"${pkgs.kanata.passthru.darwinDriver}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon\"";
    serviceConfig.ProcessType = "Interactive";
    serviceConfig.Label = "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice-Daemon";
    serviceConfig.KeepAlive = true;
  };

  launchd.daemons.kanata = {
    # also need to add kanata binary to System Settings -> Privacy & Security -> Input Monitoring
    command = "${lib.getExe pkgs.kanata} --cfg ${kbdCfg}";
    # command = "${lib.getExe pkgs.kanata} --cfg ../../kanata/piantor_thinkpad_macos.kbd";
    serviceConfig.ProcessType = "Interactive";
    serviceConfig.Label = "org.nixos.kanata";
    serviceConfig.KeepAlive = true;
  };
}
