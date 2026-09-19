{ tsg, ... }:

{
  nixpkgs.overlays = [
    (import ./llm.nix)
    (import ./llm-proxy.nix)
    (import ./tilth.nix)
    (import ./tp-smapi.nix)
    (import ./mlc.nix)
    (import ./llama-cpp.nix)
    (import ./llama-benchy.nix)
    ((import ./touchscreen-gestures.nix) { inherit tsg; })
  ];
}
