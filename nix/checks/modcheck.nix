{ pkgs, self' }:

let
  modcheck = self'.packages.modcheck;
  expectedVersion = "0.2.1";
in
pkgs.runCommand "test-modcheck"
{
  nativeBuildInputs = [ modcheck ];
  meta.description = "Smoke tests for the modcheck derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR

  echo "==> modcheck on PATH"
  command -v modcheck

  echo "==> modcheck --version matches pin (${expectedVersion})"
  version=$(modcheck --version 2>&1)
  echo "    got: $version"
  [[ "$version" == *"modcheck version ${expectedVersion}" ]] || {
    echo "ERROR: expected ${expectedVersion}, got: $version"
    exit 1
  }

  # A real scan queries the vulnerability database and GitHub, which the
  # sandbox cannot reach, so only the CLI surface is exercised here.
  echo "==> modcheck --help advertises the usage banner"
  help_output=$(modcheck --help 2>&1)
  [[ "$help_output" == *"modcheck [path] [flags]"* ]] || {
    echo "ERROR: modcheck --help did not show the usage banner"
    exit 1
  }

  touch $out
''
