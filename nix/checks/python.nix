{ pkgs, self' }:

let
  python = self'.packages.python;
  expectedVersion = "3.14.5";
in
pkgs.runCommand "test-python"
{
  nativeBuildInputs = [ python ];
  meta.description = "Smoke tests for the python derivation";
} ''
    set -euo pipefail
    export HOME=$TMPDIR

    echo "==> python3 on PATH"
    command -v python3

    echo "==> python3 --version matches pin (${expectedVersion})"
    version=$(python3 --version 2>&1)
    echo "    got: $version"
    echo "$version" | grep -q "Python ${expectedVersion}" || {
      echo "ERROR: expected Python ${expectedVersion}, got: $version"
      exit 1
    }

    echo "==> sys.version_info reports the pinned major.minor"
    python3 -c '
    import sys
    assert sys.version_info[:3] == (3, 14, 5), sys.version_info
    print("sys.version_info OK:", sys.version_info)
    '

    echo "==> stdlib modules import and round-trip"
    python3 -c '
    import json, hashlib, base64, urllib.parse
    payload = {"x": 1, "y": [2, 3]}
    blob = json.dumps(payload).encode()
    digest = hashlib.sha256(blob).hexdigest()
    encoded = base64.b64encode(blob).decode()
    assert json.loads(base64.b64decode(encoded)) == payload
    assert len(digest) == 64
    assert urllib.parse.quote("a b") == "a%20b"
    print("stdlib OK")
    '

    echo "==> python3 executes a script file"
    cat > "$TMPDIR/script.py" <<'EOF'
  import sys

  def fib(n):
      a, b = 0, 1
      for _ in range(n):
          a, b = b, a + b
      return a

  if __name__ == "__main__":
      assert fib(10) == 55
      sys.stdout.write("script ok\n")
  EOF
    script_out=$(python3 "$TMPDIR/script.py")
    [ "$script_out" = "script ok" ] || {
      echo "ERROR: unexpected script output: $script_out"
      exit 1
    }

    touch $out
''
