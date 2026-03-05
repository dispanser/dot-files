final: prev: {
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
}
