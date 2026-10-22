{ pkgs, self' }:

let
  golangci-lint = self'.packages.golangci-lint;
  expectedVersion = "2.15.0";
in
pkgs.runCommand "test-golangci-lint"
{
  nativeBuildInputs = [ golangci-lint ];
  meta.description = "Smoke tests for the golangci-lint derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR

  echo "==> golangci-lint on PATH"
  command -v golangci-lint

  echo "==> golangci-lint --version matches pin (${expectedVersion})"
  version=$(golangci-lint --version 2>&1)
  echo "    got: $version"
  [[ "$version" =~ (^|[^0-9])${expectedVersion}([^0-9]|$) ]] || {
    echo "ERROR: expected ${expectedVersion}, got: $version"
    exit 1
  }

  touch $out
''
