final: prev: {
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
}
