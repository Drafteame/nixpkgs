{ pkgs, self' }:

let
  goimports-reviser = self'.packages.goimports-reviser;
  expectedVersion = "3.13.2";
in
pkgs.runCommand "test-goimports-reviser"
{
  nativeBuildInputs = [ goimports-reviser ];
  meta.description = "Smoke tests for the goimports-reviser derivation";
} ''
    set -euo pipefail
    export HOME=$TMPDIR

    echo "==> goimports-reviser on PATH"
    command -v goimports-reviser

    echo "==> goimports-reviser -version matches pin (${expectedVersion})"
    version=$(goimports-reviser -version 2>&1)
    echo "    got: $version"
    [[ "$version" == *"version: ${expectedVersion}"* ]] || {
      echo "ERROR: expected ${expectedVersion}, got: $version"
      exit 1
    }

    # Regression: a tool with an outdated std list treats encoding/json/jsontext
    # as a third-party import and does not split it from the other groups.
    echo "==> encoding/json/jsontext is grouped as standard library"
    mkdir probe
    cat > probe/go.mod <<'EOF'
  module example.com/probe

  go 1.27
  EOF
    cat > probe/probe.go <<'EOF'
  package probe

  import (
  	"github.com/example/dep"
  	"encoding/json/jsontext"
  )

  var _ = dep.X
  var _ = jsontext.Value(nil)
  EOF
    (cd probe && goimports-reviser -output stdout probe.go 2>/dev/null > out.go)
    expected=$(printf '\t"encoding/json/jsontext"\n\n\t"github.com/example/dep"')
    [[ "$(cat probe/out.go)" == *"$expected"* ]] || {
      echo "ERROR: jsontext was not grouped as std; output was:"
      cat probe/out.go
      exit 1
    }

    touch $out
''
