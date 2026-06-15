{ pkgs, self' }:

let
  migrate = self'.packages.go-migrate;
  expectedVersion = "4.19.1";
in
pkgs.runCommand "test-go-migrate"
{
  nativeBuildInputs = [ migrate ];
  meta.description = "Smoke tests for the go-migrate derivation";
} ''
  set -euo pipefail

  echo "==> migrate on PATH"
  command -v migrate

  echo "==> migrate -version matches pin (${expectedVersion})"
  # migrate prints its version to stderr.
  version=$(migrate -version 2>&1)
  echo "    got: $version"
  [[ "$version" =~ (^|[^0-9])${expectedVersion}([^0-9]|$) ]] || {
    echo "ERROR: expected ${expectedVersion}, got: $version"
    exit 1
  }

  echo "==> migrate -help advertises the usage banner"
  help_output=$(migrate -help 2>&1 || true)
  [[ "$help_output" == *"Usage: migrate"* ]] || {
    echo "ERROR: migrate -help did not show the usage banner"
    exit 1
  }

  touch $out
''
