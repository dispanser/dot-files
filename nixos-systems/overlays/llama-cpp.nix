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
    npmDepsHash = "sha256-DxgUDVr+kwtW55C4b89Pl+j3u2ILmACcQOvOBjKWAKQ=";
    version = "8667";
    src = prev.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b8667";
      hash = "sha256-73JfQWN/mPFV82Qod61AgxMpSrgh0Lz/NEsf1ljZHXc=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };
  });
}
