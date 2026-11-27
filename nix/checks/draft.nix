{ pkgs, self' }:

let
  draft = self'.packages.draft;
  expectedVersion = "1.28.0";
in
pkgs.runCommand "test-draft"
{
  nativeBuildInputs = [ draft ];
  meta.description = "Smoke tests for the draft derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR

  echo "==> draft on PATH"
  command -v draft

  echo "==> draft --version matches pin (${expectedVersion})"
  version=$(draft --version 2>&1)
  echo "    got: $version"
  [[ "$version" == *"draft version ${expectedVersion}" ]] || {
    echo "ERROR: expected ${expectedVersion}, got: $version"
    exit 1
  }

  echo "==> draft --help lists the scaffolding commands"
  help_output=$(draft --help 2>&1)
  for cmd in new:service new:lambda; do
    [[ "$help_output" == *"$cmd"* ]] || {
      echo "ERROR: draft --help does not list $cmd"
      exit 1
    }
  done

  touch $out
''
