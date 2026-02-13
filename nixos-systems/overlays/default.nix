{ tsg, ... }:

{
  nixpkgs.overlays = [
    (import ./llm.nix)

    (final: prev: {
      touchscreen-gestures = tsg.packages.${prev.stdenv.hostPlatform.system}.default;
    })

    (final: prev: {
      tilth = prev.rustPlatform.buildRustPackage rec {
        pname = "tilth";
        version = "0.2.1";

        src = prev.fetchFromGitHub {
          owner = "jahala";
          repo = "tilth";
          rev = "af63490";
          hash = "sha256-+/XMWRzAJt0wOEW1L4R8vIeSiUHJXNRKUAM2e4O1amo="; 
        };

        cargoLock.lockFile = "${src}/Cargo.lock";

        meta = with prev.lib; {
          description = "tilth — tree-sitter indexed lookups — smart code reading for AI agents";
          homepage = "https://github.com/jahala/tilth";
          license = licenses.mit;
          mainProgram = "tilth";
        };
      };
    })

    (final: prev: {
      tuicr = prev.rustPlatform.buildRustPackage rec {
        pname = "tuicr";
        version = "0.7.2";

        src = prev.fetchFromGitHub {
          owner = "agavra";
          repo = "tuicr";
          rev = "fca520d";
          hash = "sha256-ekG8TMhRJq4XHSRqOaNIeH+798Lgk/Nd9PAU2d3EoJ8=";
        };

        cargoLock.lockFile = "${src}/Cargo.lock";
        doCheck = false;

        meta = with prev.lib; {
          description = "Review AI-generated diffs like a GitHub pull request, right from your terminal.";
          homepage = "https://github.com/agavra/tuicr";
          license = licenses.mit;
          mainProgram = "tuicr";
        };
      };
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
        version = "7983";
        src = prev.fetchFromGitHub {
          owner = "ggml-org";
          repo = "llama.cpp";
          # tag = "b7983";
          rev = "854b09f0d7825dd9b8ca542a7f63c2374d66121a";
          hash = "sha256-v5etW3YcyCP8IjEO2pUNdqIx3uYSczWGSePVW7+gWjc=";
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
