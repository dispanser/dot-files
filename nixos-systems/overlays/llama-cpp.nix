final: prev: {
  llama-cpp = (prev.llama-cpp.override {
    cudaSupport = true;
    rocmGpuTargets = [ "gfx1201" ];
    rocmSupport = false;
    rpcSupport = false;
    blasSupport = true;
  }).overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      (prev.lib.cmakeBool "GGML_CPU_ALL_VARIANTS" true)
      (prev.lib.cmakeBool "GGML_BACKEND_DL" true)
      (prev.lib.cmakeBool "LLAMA_CURL" false)
      # (prev.lib.cmakeBool "GGML_HIP_UMA" true)
      # (prev.lib.cmakeBool "GGML_HIP_GRAPHS" true)
    ];
    # npmDepsHash = "sha256-RAFtsbBGBjteCt5yXhrmHL39rIDJMCFBETgzId2eRRk=";
    npmDepsHash = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";
    version = "10944";
    src = prev.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b10944";
      hash = "sha256-n+klGaNY/r4246CeLLooM9RZ5WepId1+qKXTkMYKAYQ=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };
  });
}
