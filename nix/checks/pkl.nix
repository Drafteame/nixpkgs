{ pkgs, self' }:

let
  pkl = self'.packages.pkl;
  expectedVersion = "0.31.1";
in
pkgs.runCommand "test-pkl"
{
  nativeBuildInputs = [ pkl ];
  meta.description = "Smoke tests for the pkl derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR

  echo "==> pkl on PATH"
  command -v pkl

  echo "==> pkl --version matches pin (${expectedVersion})"
  version=$(pkl --version)
  echo "    got: $version"
  echo "$version" | grep -qE "(^|[^0-9])${expectedVersion}([^0-9]|$)" || {
    echo "ERROR: expected ${expectedVersion}, got: $version"
    exit 1
  }

  echo "==> pkl eval renders a minimal module"
  cat > "$TMPDIR/hello.pkl" <<'EOF'
  name = "world"
  greeting = "hello, \(name)"
  numbers = List(1, 2, 3)
  EOF
  result=$(pkl eval "$TMPDIR/hello.pkl")
  echo "$result"
  echo "$result" | grep -q 'greeting = "hello, world"'
  echo "$result" | grep -qE 'numbers = (List\()?1, 2, 3'

  touch $out
''
