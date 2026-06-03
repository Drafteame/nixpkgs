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
  echo "$version" | grep -qE "(^|[^0-9])${expectedVersion}([^0-9]|$)" || {
    echo "ERROR: expected ${expectedVersion}, got: $version"
    exit 1
  }

  echo "==> migrate -help advertises the usage banner"
  migrate -help 2>&1 | grep -q "Usage: migrate"

  touch $out
''
