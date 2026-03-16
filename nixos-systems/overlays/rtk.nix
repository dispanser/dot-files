final: prev: {
  rtk = prev.rustPlatform.buildRustPackage rec {
    pname = "rtk";
    version = "0.30.0";

    src = prev.fetchFromGitHub {
      owner = "rtk-ai";
      repo = "rtk";
      rev = "v${version}";
      hash = "sha256-aB9SWF9jYHeH3Apz5v4mQptLa6tS9cIfyfo6rHqsD8w=";
    };

    cargoLock.lockFile = "${src}/Cargo.lock";
    doCheck = false;

    meta = with prev.lib; {
      description = "CLI proxy that reduces LLM token consumption by 60-90% on common dev commands";
      homepage = "https://github.com/rtk-ai/rtk";
      license = licenses.mit;
      mainProgram = "rtk";
    };
  };
}
