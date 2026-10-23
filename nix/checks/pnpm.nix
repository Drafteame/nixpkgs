{ pkgs, self' }:

let
  node = self'.packages.node;
  pnpm = self'.packages.pnpm;
  expectedVersion = "12.15.0";
in
pkgs.runCommand "test-pnpm"
{
  nativeBuildInputs = [ pnpm ];
  meta.description = "Smoke tests for the pnpm derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR/home
  mkdir -p "$HOME"

  echo "==> pnpm on PATH"
  command -v pnpm

  echo "==> pnpm --version matches pin (${expectedVersion})"
  version=$(pnpm --version)
  echo "    got: $version"
  [ "$version" = "${expectedVersion}" ] || {
    echo "ERROR: expected ${expectedVersion}, got: $version"
    exit 1
  }

  echo "==> global bin dir defaults to \$HOME/.pnpm-global/bin"
  [ "$(pnpm bin -g)" = "$HOME/.pnpm-global/bin" ] || {
    echo "ERROR: unexpected global bin dir: $(pnpm bin -g)"
    exit 1
  }

  echo "==> PNPM_HOME overrides the default"
  [ "$(PNPM_HOME=$TMPDIR/custom pnpm bin -g)" = "$TMPDIR/custom/bin" ]

  echo "==> pnpm add -g lands under \$HOME/.pnpm-global"
  mkdir -p "$TMPDIR/src/package"
  cat > "$TMPDIR/src/package/package.json" <<'JSON'
  {"name":"draftea-hello","version":"1.0.0","bin":{"draftea-hello":"cli.js"}}
  JSON
  printf '#!/usr/bin/env node\nconsole.log("ok")\n' > "$TMPDIR/src/package/cli.js"
  chmod +x "$TMPDIR/src/package/cli.js"
  (cd "$TMPDIR/src" && tar czf hello.tgz package)
  pnpm add -g --offline "$TMPDIR/src/hello.tgz"
  [ -e "$HOME/.pnpm-global/bin/draftea-hello" ]
  [ "$(PATH=${node}/bin:$HOME/.pnpm-global/bin draftea-hello)" = "ok" ]

  echo "==> setup hook puts the global bin dir on PATH"
  (
    PATH=/nonexistent
    . ${pnpm}/nix-support/setup-hook
    [[ ":$PATH:" == *":$HOME/.pnpm-global/bin:"* ]]
  )

  touch $out
''
