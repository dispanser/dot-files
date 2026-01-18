{ tsg, ... }:

{
  nixpkgs.overlays = [
    (import ./llm.nix)

    (final: prev: {
      touchscreen-gestures = tsg.packages.${prev.stdenv.hostPlatform.system}.default;
    })

    (final: prev: {
      llamalol = (prev.llama-cpp.override {
        cudaSupport = false;
        rocmGpuTargets = [ "gfx1201" ];
        rocmSupport = true;
        rpcSupport = true;
      }).overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags ++ [
          (prev.lib.cmakeBool "GGML_CPU_ALL_VARIANTS" true)
          (prev.lib.cmakeBool "GGML_BACKEND_DL" true)
          (prev.lib.cmakeBool "GGML_HIP_UMA" true)
          (prev.lib.cmakeBool "GGML_HIP_GRAPHS" true)
        ];
        version = "7770";
        src = prev.fetchFromGitHub {
          owner = "ggml-org";
          repo = "llama.cpp";
          tag = "b7770";
          hash = "sha256-SRz8uLjXtjpHhekqrksUc7oUuz6cYdWfvcdHxWNEgbs=";
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
