{ tsg, ... }:

{
  nixpkgs.overlays = [
    (import ./llm.nix)
    (import ./tilth.nix)
    (import ./tuicr.nix)
    (import ./rtk.nix)
    (import ./mlc.nix)
    (import ./llama-cpp.nix)
    ((import ./touchscreen-gestures.nix) { inherit tsg; })
  ];
}
