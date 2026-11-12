# nuru (a private checkout without a git remote) drives the niri session
# workflows: project terminals, the project browser, and spawn-or-focus
# shortcuts. The flake takes it in as a `git+file` input with `flake = false`.
# A clean checkout contributes its committed tree, so the build stays pure; a
# dirty checkout is built from its worktree instead, so commit changes there
# and run `nix flake update nuru` to pin them. Refresh `cargoHash` when
# Cargo.lock changes (build once with a bogus hash and read the "got:" value
# from the error). Once the repository has a remote, only the input URLs
# change.
{ nuru }:
final: prev:
let
  # The devenv definitions and the agent notes change independently of the
  # code; filter them out to keep rebuilds down. Untracked build output such as
  # `target/` is excluded by the checkout's .gitignore.
  srcFilter =
    path: _type:
    !(prev.lib.elem (baseNameOf path) [
      "AGENTS.md"
      "devenv.lock"
      "devenv.nix"
      "devenv.yaml"
    ]);
  src = prev.lib.cleanSourceWith {
    src = nuru;
    filter = srcFilter;
  };
in
{
  nuru = prev.rustPlatform.buildRustPackage rec {
    pname = "nuru";
    version = "0.1.0";

    inherit src;

    cargoHash = "sha256-9zgw09AKjKpK+vwSwOAzofmn8wfm+ottf8W3UpKMui8=";

    # The checkout has no test suite; it is exercised with `cargo nextest run`
    # during development.
    doCheck = false;

    meta = with prev.lib; {
      description = "Niri session helper for project terminals, browser, and spawn-or-focus workflows";
      homepage = "https://github.com/dispanser/nuru";
      mainProgram = "nuru";
    };
  };
}
