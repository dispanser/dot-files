final: prev: {
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
    npmDepsHash = "sha256-eeftjKt0FuS0Dybez+Iz9VTVMA4/oQVh+3VoIqvhVMw=";
    version = "8668";
    src = prev.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      rev = "d6f303004";
      hash = "sha256-k0Spo0+3/eH639my33fH9+kOypUyTg1lg8/3+ynU1+Q=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };
  });
}
