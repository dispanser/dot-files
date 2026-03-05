{ tsg }:
final: prev: {
  touchscreen-gestures = tsg.packages.${prev.stdenv.hostPlatform.system}.default;
}
