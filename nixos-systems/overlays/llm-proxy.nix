# llm-proxy (https://github.com/dispanser/llm-proxy) is a private checkout
# without a git remote, so — like ./mlc.nix — the source is pinned to the local
# working copy via `builtins.path`, which needs `nixos-rebuild --impure`.
#
# Refresh `cargoHash` when Cargo.lock changes (build once with a bogus hash and
# read the "got:" value from the error). Once the repository has a remote, swap
# `src` for fetchFromGitHub and the impurity goes away.
final: prev:
let
  # Keep the source small and rebuild-stable: `target/` is a multi-gigabyte
  # cargo directory, the editor/devenv state directories are never part of the
  # build, and `agent/` + `docs/` are notes that change independently of code.
  # `scripts/` stays in: the hook scripts ship with the program.
  srcFilter =
    path: _type:
    let
      name = baseNameOf path;
    in
    !(prev.lib.elem name [
      "target"
      "result"
      ".git"
      ".direnv"
      ".devenv"
      ".tp"
      ".cargo"
      ".github"
      ".envrc"
      "agent"
      "docs"
    ]);
  src = prev.lib.cleanSourceWith {
    src = builtins.path {
      name = "llm-proxy-src";
      path = /home/pi/src/github/dispanser/llm-proxy;
      filter = srcFilter;
    };
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