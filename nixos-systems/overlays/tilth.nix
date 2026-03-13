final: prev: {
  tilth = prev.rustPlatform.buildRustPackage rec {
    pname = "tilth";
    version = "0.4.3";

    src = prev.fetchFromGitHub {
      owner = "jahala";
      repo = "tilth";
      tag = "v0.5.1";
      hash = "sha256-XtnHWx6kTlqm0AYz/LcAjkI54Vkh79Ddm0+8As5Ufds=";
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
