{ pkgs, self' }:

let
  staticcheck = self'.packages.staticcheck;
  expectedVersion = "2026.2.2";
in
pkgs.runCommand "test-staticcheck"
{
  nativeBuildInputs = [ staticcheck ];
  meta.description = "Smoke tests for the staticcheck derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR

  echo "==> staticcheck on PATH"
  command -v staticcheck

  echo "==> staticcheck -version matches pin (${expectedVersion})"
  version=$(staticcheck -version 2>&1)
  echo "    got: $version"
  [[ "$version" == *"${expectedVersion}"* ]] || {
    echo "ERROR: expected ${expectedVersion}, got: $version"
    exit 1
  }

  touch $out
''
