final: prev:
let
  python = final.python3;
in
{
  llama-benchy = python.pkgs.buildPythonApplication rec {
    pname = "llama-benchy";
    version = "0.4.0";
    pyproject = true;

    # the sdist is published under the normalized (underscored) name
    src = final.fetchPypi {
      pname = "llama_benchy";
      inherit version;
      sha256 = "sha256-Q5lKbqn/iTs4WfN4DPKECfxJe2zSgbWUMEhysP1LGhU=";
    };

    # the project is versioned from git tags (hatch-vcs); the sdist already ships
    # src/llama_benchy/_version.py and PKG-INFO, so no git is needed.
    # `asyncio` is an obsolete PyPI stub for what has been stdlib forever - drop it,
    # it is not packaged in nixpkgs and would fail the pyproject dependency check.
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail '"asyncio",' ""
    '';

    nativeBuildInputs = with python.pkgs; [
      hatchling
      hatch-vcs
    ];

    dependencies = with python.pkgs; [
      aiohttp
      numpy
      openai
      pydantic
      requests
      tabulate
      tokenizers
      transformers
    ];

    # tests drive a local fastapi/uvicorn mock server
    nativeCheckInputs = with python.pkgs; [
      fastapi
      pytest-asyncio
      pytestCheckHook
      uvicorn
    ];

    # the mock-server integration tests download a tokenizer from huggingface
    disabledTestPaths = [ "tests/test_mock_integration.py" ];

    pythonImportsCheck = [ "llama_benchy" ];

    meta = with final.lib; {
      description = "llama-bench style benchmarking tool for all OpenAI-compatible LLM endpoints";
      homepage = "https://github.com/eugr/llama-benchy";
      changelog = "https://github.com/eugr/llama-benchy/releases/tag/v${version}";
      license = licenses.mit;
      mainProgram = "llama-benchy";
    };
  };
}