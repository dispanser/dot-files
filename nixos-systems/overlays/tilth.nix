final: prev: {
  tilth = prev.rustPlatform.buildRustPackage rec {
    pname = "tilth";
    version = "0.9.0";

    src = prev.fetchFromGitHub {
      owner = "jahala";
      repo = "tilth";
      tag = "v0.9.0";
      hash = "sha256-EETGfQQbDerW4YmVync9RW7asbqRVHK4kOfnnvNjQG4=";
    };

    cargoLock.lockFile = "${src}/Cargo.lock";

    # diff::tests depend on a real git repo/config not available in the sandbox
    doCheck = false;

    meta = with prev.lib; {
      description = "tilth — tree-sitter indexed lookups — smart code reading for AI agents";
      homepage = "https://github.com/jahala/tilth";
      license = licenses.mit;
      mainProgram = "tilth";
    };
  };
}
