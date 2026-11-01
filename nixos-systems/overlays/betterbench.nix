final: prev:
let
  python = final.python3;
in
{
  betterbench = python.pkgs.buildPythonApplication rec {
    pname = "betterbench";
    version = "0.6.1";
    pyproject = true;

    # Not on PyPI, so the release tarball is the source. hatchling reads the
    # version from betterbench/__init__.py, which the tarball ships, so no git
    # metadata is needed.
    src = final.fetchFromGitHub {
      owner = "GGZ14";
      repo = "BetterBench";
      tag = "v${version}";
      hash = "sha256-3F5sVCpdagQAphvZaWecEArkA04E+D8ck5QPCqauSh8=";
    };

    build-system = [ python.pkgs.hatchling ];

    dependencies = [ python.pkgs.numpy ];

    # the suite drives a mock OpenAI server on port 0 and its conftest disables
    # the release check, so no test reaches the network
    nativeCheckInputs = [ python.pkgs.pytestCheckHook ];

    pythonImportsCheck = [ "betterbench" ];

    meta = {
      description = "Percentile-based LLM inference benchmark for any OpenAI-compatible endpoint";
      homepage = "https://github.com/GGZ14/BetterBench";
      changelog = "https://github.com/GGZ14/BetterBench/releases/tag/v${version}";
      license = final.lib.licenses.asl20;
      mainProgram = "betterbench";
    };
  };
}
