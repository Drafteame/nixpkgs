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
  [[ "$version" =~ (^|[^0-9])${expectedVersion}([^0-9]|$) ]] || {
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
  [[ "$result" == *'greeting = "hello, world"'* ]] || {
    echo "ERROR: greeting line missing from pkl output"
    exit 1
  }
  [[ "$result" =~ numbers\ =\ (List\()?1,\ 2,\ 3 ]] || {
    echo "ERROR: numbers list missing from pkl output"
    exit 1
  }

  touch $out
''
