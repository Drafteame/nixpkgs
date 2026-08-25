{ pkgs, self' }:

let
  mockery = self'.packages.mockery;
  go = self'.packages.go;
  expectedVersion = "3.7.4";
in
pkgs.runCommand "test-mockery"
{
  nativeBuildInputs = [ mockery go ];
  meta.description = "Smoke tests for the mockery derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR
  export GOCACHE=$TMPDIR/go-cache
  export GOPATH=$TMPDIR/go
  export GOMODCACHE=$TMPDIR/go-mod
  export GOFLAGS=-mod=mod

  echo "==> mockery on PATH"
  command -v mockery

  echo "==> mockery version matches pin (${expectedVersion})"
  version=$(mockery version 2>&1)
  echo "    got: $version"
  [[ "$version" =~ (^|[^0-9])${expectedVersion}([^0-9]|$) ]] || {
    echo "ERROR: expected ${expectedVersion}, got: $version"
    exit 1
  }

  echo "==> mockery --help advertises the v3 command set"
  help_output=$(mockery --help 2>&1)
  [[ "$help_output" == *"Generate mock objects for your Go interfaces"* ]] || {
    echo "ERROR: mockery --help did not show the usage banner"
    exit 1
  }
  # `showconfig` only exists in v3; guards against silently shipping a v2 binary.
  [[ "$help_output" == *"showconfig"* ]] || {
    echo "ERROR: mockery --help is missing the v3 'showconfig' command"
    exit 1
  }

  mkdir -p "$TMPDIR/proj/greeter"
  cd "$TMPDIR/proj"
  cat > go.mod <<'EOF'
  module example.com/proj

  go 1.24
  EOF

  cat > greeter/greeter.go <<'EOF'
  package greeter

  type Greeter interface {
    Greet(name string) (string, error)
  }
  EOF

  echo "==> mockery init writes a v3 config scaffold"
  mockery init example.com/proj
  [ -f .mockery.yml ] || { echo "ERROR: mockery init did not write .mockery.yml"; exit 1; }
  grep -q "^template:" .mockery.yml || {
    echo "ERROR: scaffolded config is missing the v3 'template' key"
    exit 1
  }

  echo "==> mockery generates a mock for a local interface"
  # The matryer template keeps the generated mock dependency-free, so the compile
  # step below stays offline (the testify template would need a module download).
  cat > .mockery.yml <<'EOF'
  all: false
  log-level: warn
  dir: '{{.InterfaceDir}}'
  filename: mock_greeter.go
  structname: 'Mock{{.InterfaceName}}'
  pkgname: '{{.SrcPackageName}}'
  template: matryer
  packages:
    example.com/proj/greeter:
      config:
        all: true
  EOF

  echo "==> mockery showconfig reads the config back"
  # showconfig forces debug logging on stderr; keep it out of the build log unless it fails.
  mockery showconfig >/dev/null 2>"$TMPDIR/showconfig.err" || {
    cat "$TMPDIR/showconfig.err"
    echo "ERROR: mockery showconfig failed"
    exit 1
  }

  mockery --log-level warn

  generated="greeter/mock_greeter.go"
  [ -f "$generated" ] || { echo "ERROR: mockery did not write $generated"; exit 1; }
  grep -q "type MockGreeter struct" "$generated" || {
    echo "ERROR: generated file is missing the MockGreeter type"
    exit 1
  }

  echo "==> generated mock compiles"
  go build ./...

  touch $out
''
