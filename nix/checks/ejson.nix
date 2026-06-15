{ pkgs, self' }:

# ejson has no `--version` / `version` subcommand, so version pinning is
# enforced at the derivation level and we exercise the binary via a real
# `keygen` invocation here. If the wrong tarball was unpacked, this fails
# because keygen output structure changes across major versions.

let
  ejson = self'.packages.ejson;
in
pkgs.runCommand "test-ejson"
{
  nativeBuildInputs = [ ejson ];
  meta.description = "Smoke tests for the ejson derivation";
} ''
  set -euo pipefail
  export HOME=$TMPDIR

  echo "==> ejson on PATH"
  command -v ejson

  echo "==> ejson keygen produces a Curve25519 keypair"
  ejson keygen > "$TMPDIR/keys.txt"
  grep -q "^Public Key:$"  "$TMPDIR/keys.txt"
  grep -q "^Private Key:$" "$TMPDIR/keys.txt"

  # Public and private keys are 32-byte hex strings (64 chars).
  pub=$(sed -n '2p' "$TMPDIR/keys.txt")
  priv=$(sed -n '4p' "$TMPDIR/keys.txt")
  [ "''${#pub}"  -eq 64 ] || { echo "ERROR: bad public key length: ''${#pub}";  exit 1; }
  [ "''${#priv}" -eq 64 ] || { echo "ERROR: bad private key length: ''${#priv}"; exit 1; }

  echo "==> ejson encrypt round-trips a file"
  mkdir -p "$TMPDIR/keys" "$TMPDIR/work"
  echo -n "$priv" > "$TMPDIR/keys/$pub"

  cat > "$TMPDIR/work/secret.ejson" <<EOF
  {
    "_public_key": "$pub",
    "value": "hello"
  }
  EOF
  ejson encrypt "$TMPDIR/work/secret.ejson"
  grep -q 'EJ\[1' "$TMPDIR/work/secret.ejson"

  decrypted=$(EJSON_KEYDIR="$TMPDIR/keys" ejson decrypt "$TMPDIR/work/secret.ejson")
  [[ "$decrypted" == *'"value": "hello"'* ]] || {
    echo "ERROR: decrypted payload missing expected value: $decrypted"
    exit 1
  }

  touch $out
''
