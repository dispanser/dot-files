final: prev: {
  tilth = prev.rustPlatform.buildRustPackage rec {
    pname = "tilth";
    version = "0.4.3";

    src = prev.fetchFromGitHub {
      owner = "jahala";
      repo = "tilth";
      tag = "v0.4.3";
      hash = "sha256-uvc8nrJw0DyITUtTnPjQu7z43Hc9ExOV4mJ+wJ1hA6Y=";
    };

    cargoLock.lockFile = "${src}/Cargo.lock";

    meta = with prev.lib; {
      description = "tilth — tree-sitter indexed lookups — smart code reading for AI agents";
      homepage = "https://github.com/jahala/tilth";
      license = licenses.mit;
      mainProgram = "tilth";
    };
  };
}
