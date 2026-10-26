# unifi-controller 10.6.106 fails auto-patchelf: libubnt_webrtc_jni.so needs
# libstdc++.so.6 and libgcc_s.so.1, but the package builds with stdenvNoCC and
# lists no C++ runtime, so the libraries are never handed to patchelf.
# NixOS/nixpkgs#576949; fixed on master by NixOS/nixpkgs#575661, which adds
# stdenv.cc.cc.lib as a build input.
#
# Drop this overlay once nixos-unstable carries that commit.
final: prev: {
  unifi = prev.unifi.overrideAttrs (old: {
    buildInputs = old.buildInputs or [ ] ++ [ final.stdenv.cc.cc.lib ];
  });
}
