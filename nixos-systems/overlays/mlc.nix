final: prev: {
  # https://downloadmirror.intel.com/866182/mlc_v3.12.tgz
  mlc = prev.mlc.overrideAttrs (old: {
    version = "3.12";
    src = builtins.path {
      name = "mlc_v3.12.tgz";
      path = /home/pi/src/github/dispanser/dot-files/archives/mlc_v3.12.tgz;
    };
  });
}
