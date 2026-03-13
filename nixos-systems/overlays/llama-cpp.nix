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
    npmDepsHash = "sha256-5ZswgZFLeI32/xQZqCTTFbCzleDqr5AotjFg/5rNn1M=";
    version = "8200";
    src = prev.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b8305";
      # rev = "c5a778891ba0ddbd4cbb507c823f970595b1adc2";
      hash = "sha256-vikUHO7A4ey4H1JV8dHiqflt3kYpvgz9YW6681Y4JW8=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };
  });
}
