{ pkgs, self' }:

let
  go = self'.packages.go;
  expectedVersion = "1.26.4";
in
pkgs.runCommand "test-go"
{
  nativeBuildInputs = [ go ];
  meta.description = "Smoke tests for the go derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR
  export GOCACHE=$TMPDIR/go-cache
  export GOPATH=$TMPDIR/go
  export GOMODCACHE=$TMPDIR/go-mod
  export GOFLAGS=-mod=mod

  echo "==> go and gofmt on PATH"
  command -v go
  command -v gofmt

  echo "==> go version matches pin (${expectedVersion})"
  version=$(go version)
  echo "    got: $version"
  [[ "$version" == *"go${expectedVersion} "* ]] || {
    echo "ERROR: expected go${expectedVersion}, got: $version"
    exit 1
  }

  echo "==> GOROOT resolves to the derivation"
  goroot=$(go env GOROOT)
  echo "    GOROOT=$goroot"
  [ -x "$goroot/bin/go" ] || { echo "ERROR: GOROOT missing go binary"; exit 1; }

  echo "==> gofmt formats a sample file"
  mkdir -p "$TMPDIR/src"
  cat > "$TMPDIR/src/main.go" <<'EOF'
  package main
  import "fmt"
  func main() { fmt.Println("ok") }
  EOF
  gofmt -l "$TMPDIR/src" || true

  echo "==> go build compiles a stdlib-only program offline"
  mkdir -p "$TMPDIR/build"
  cat > "$TMPDIR/build/main.go" <<'EOF'
  package main

  import "fmt"

  func main() {
    fmt.Println("hello from go test")
  }
  EOF
  cd "$TMPDIR/build"
  go mod init testbin >/dev/null
  go build -o "$TMPDIR/build/testbin" ./...
  bin_out=$("$TMPDIR/build/testbin")
  [ "$bin_out" = "hello from go test" ] || {
    echo "ERROR: unexpected program output: $bin_out"
    exit 1
  }

  touch $out
''
