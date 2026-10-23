{ pkgs, self' }:

let
  node = self'.packages.node;
  npm = self'.packages.npm;
  expectedVersion = "11.20.0";
in
pkgs.runCommand "test-npm"
{
  nativeBuildInputs = [ npm ];
  meta.description = "Smoke tests for the npm derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR/home
  mkdir -p "$HOME"

  echo "==> npm on PATH"
  command -v npm

  echo "==> npm --version matches pin (${expectedVersion})"
  version=$(npm --version)
  echo "    got: $version"
  [ "$version" = "${expectedVersion}" ] || {
    echo "ERROR: expected ${expectedVersion}, got: $version"
    exit 1
  }

  echo "==> global prefix defaults to \$HOME/.npm-global"
  [ "$(npm config get prefix)" = "$HOME/.npm-global" ] || {
    echo "ERROR: unexpected prefix: $(npm config get prefix)"
    exit 1
  }

  echo "==> NPM_CONFIG_PREFIX overrides the default"
  [ "$(NPM_CONFIG_PREFIX=$TMPDIR/custom npm config get prefix)" = "$TMPDIR/custom" ]

  echo "==> npm install -g lands under \$HOME/.npm-global"
  mkdir -p "$TMPDIR/pkg"
  cat > "$TMPDIR/pkg/package.json" <<'JSON'
  {"name":"draftea-hello","version":"1.0.0","bin":{"draftea-hello":"cli.js"}}
  JSON
  printf '#!/usr/bin/env node\nconsole.log("ok")\n' > "$TMPDIR/pkg/cli.js"
  chmod +x "$TMPDIR/pkg/cli.js"
  (cd "$TMPDIR/pkg" && npm pack --silent)
  npm install -g --offline --no-audit --no-fund "$TMPDIR/pkg/draftea-hello-1.0.0.tgz"
  [ -e "$HOME/.npm-global/bin/draftea-hello" ]
  [ "$(${node}/bin/node "$HOME/.npm-global/bin/draftea-hello")" = "ok" ]

  echo "==> setup hook puts the global bin dir on PATH"
  (
    PATH=/nonexistent
    . ${npm}/nix-support/setup-hook
    [[ ":$PATH:" == *":$HOME/.npm-global/bin:"* ]]
  )

  touch $out
''
