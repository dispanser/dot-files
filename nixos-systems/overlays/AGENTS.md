How to upgrade:

- `llama-cpp`: use the latest tag of the form `bNNNN` via `git tag --list | rg '^b\\d+' | sort -nr | head -n1`
- tuicr and tilth: use latest version tag
- `llama-benchy`: built from the PyPI sdist (upstream derives its version from git tags via
  hatch-vcs, so a GitHub tarball has no version). Check
  `curl -s https://pypi.org/pypi/llama-benchy/json | jq -r .info.version` (tags: `v0.4.0`),
  then bump `version` and the `fetchPypi` hash. Note the sdist is published under the
  normalized name `llama_benchy-<version>.tar.gz`, hence `pname = "llama_benchy"` for the fetch.
- be smart: don't pull the entire repository - what's the right command to just list remote tags?
