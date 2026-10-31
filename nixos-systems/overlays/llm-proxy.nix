# llm-proxy (https://github.com/dispanser/llm-proxy) is a private checkout
# without a git remote. The flake takes it in as a `git+file` input with
# `flake = false`, so Nix copies the committed tree into the store before
# evaluation and the build stays pure.
#
# Refresh `cargoHash` when Cargo.lock changes (build once with a bogus hash and
# read the "got:" value from the error). Once the repository has a remote, only
# the input URL changes.
{ llm-proxy }: final: prev:
let
  # Git ships only committed files, so `target/` and the editor/devenv state
  # directories never reach the input. `agent/` and `docs/` are notes that
  # change independently of code; filter them out to keep rebuilds down.
  # `scripts/` stays in: the hook scripts ship with the program.
  srcFilter = path: _type: !(prev.lib.elem (baseNameOf path) [ "agent" "docs" ]);
  src = prev.lib.cleanSourceWith {
    src = llm-proxy;
    filter = srcFilter;
  };
in
{
  llm-proxy = prev.rustPlatform.buildRustPackage rec {
    pname = "llm-proxy";
    version = "0.1.0";

    inherit src;

    cargoHash = "sha256-t//jIB+qq6aRo1vc+7e6ttcRFOlHshJjqzPQckdnwT4=";

    # The integration tests drive a real listener and an httpmock server; they
    # are exercised with `cargo test` during development, not during a Nix build.
    doCheck = false;

    meta = with prev.lib; {
      description = "LLM proxy with pre/post-request hooks (WOL, keep-awake, KV-cache slots)";
      homepage = "https://github.com/dispanser/llm-proxy";
      license = licenses.mit;
      mainProgram = "llm-proxy";
    };
  };
}