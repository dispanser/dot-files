{ tsg, ... }:

{
  nixpkgs.overlays = [
    (import ./llm.nix)

    (final: prev: {
      touchscreen-gestures = tsg.packages.${prev.stdenv.hostPlatform.system}.default;
    })
    # https://downloadmirror.intel.com/866182/mlc_v3.12.tgz
    (final: prev: {
      mlc = prev.mlc.overrideAttrs(old: {
        version = "3.12";
        src = builtins.path {
          name = "mlc_v3.12.tgz";
          path = /home/pi/src/github/dispanser/dot-files/archives/mlc_v3.12.tgz;
        };
      });
    })

    (final: prev: {
      llama-cpp = (prev.llama-cpp.override {
        cudaSupport = true;
        rocmGpuTargets = [ "gfx1201" ];
        rocmSupport = false;
        rpcSupport = true;
        blasSupport = true;
      }).overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags ++ [
          (prev.lib.cmakeBool "GGML_CPU_ALL_VARIANTS" true)
          (prev.lib.cmakeBool "GGML_BACKEND_DL" true)
          (prev.lib.cmakeBool "LLAMA_CURL" false)
          # (prev.lib.cmakeBool "GGML_HIP_UMA" true)
          # (prev.lib.cmakeBool "GGML_HIP_GRAPHS" true)
        ];
        # npmDepsHash = prev.lib.fakeHash;
        npmDepsHash = "sha256-bbv0e3HZmqpFwKELiEFBgoMr72jKbsX20eceH4XjfBA=";
        version = "7921";
        src = prev.fetchFromGitHub {
          owner = "ggml-org";
          repo = "llama.cpp";
          tag = "b7921";
          hash = "sha256-6I53fMOty6qybb/w8CTbqMN11m/ayQPQB0Mg00sCZuE=";
          leaveDotGit = true;
          postFetch = ''
            git -C "$out" rev-parse --short HEAD > $out/COMMIT
            find "$out" -name .git -print0 | xargs -0 rm -rf
          '';
        };
      });
    })
  ];
}
