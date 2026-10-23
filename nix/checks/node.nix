{ pkgs, self' }:

let
  node = self'.packages.node;
  expectedVersion = "26.12.1";
in
pkgs.runCommand "test-node"
{
  nativeBuildInputs = [ node ];
  meta.description = "Smoke tests for the node derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR

  echo "==> node on PATH"
  command -v node

  echo "==> node --version matches pin (${expectedVersion})"
  version=$(node --version)
  echo "    got: $version"
  [ "$version" = "v${expectedVersion}" ] || {
    echo "ERROR: expected v${expectedVersion}, got: $version"
    exit 1
  }

  echo "==> node executes JavaScript"
  [ "$(node -e 'console.log(1 + 1)')" = "2" ]

  echo "==> npm, npx and corepack are not bundled (optional packages)"
  for tool in npm npx corepack; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "ERROR: $tool must not be part of the node derivation"
      exit 1
    fi
  done

  echo "==> headers are present for native addons"
  [ -f ${node}/include/node/node.h ]

  touch $out
''
