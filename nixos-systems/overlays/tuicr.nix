final: prev: {
  tuicr = prev.rustPlatform.buildRustPackage rec {
    pname = "tuicr";
    version = "0.8.0";

    src = prev.fetchFromGitHub {
      owner = "agavra";
      repo = "tuicr";
      rev = "v0.8.0";
      hash = "sha256-ZZEX8JD+kiqpNsPOgrksbNrh5w8B63s8ebJplftdqhQ=";
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
