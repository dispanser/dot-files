final: prev: {
  tuicr = prev.rustPlatform.buildRustPackage rec {
    pname = "tuicr";
    version = "0.9.0";

    src = prev.fetchFromGitHub {
      owner = "agavra";
      repo = "tuicr";
      rev = "v0.9.0";
      hash = "sha256-AYZqjaJGDyQGKE5bw/dMILEheovuyyTLXWz0A+wbFGA=";
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
