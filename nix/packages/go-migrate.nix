{ pkgs }:

let
  version = "4.19.1";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/golang-migrate/migrate/releases/download/v${version}/migrate.darwin-arm64.tar.gz";
      sha256 = "0s1la18qgrhbzvlg1zy1xclhq5ax4z97zdz8g0yckhnimxbqdk58";
    };
    "x86_64-darwin" = {
      url = "https://github.com/golang-migrate/migrate/releases/download/v${version}/migrate.darwin-amd64.tar.gz";
      sha256 = "1x70jz9579nfsc44cy4yffjjlcl2g4lsmw26r1lb7a9gg78xa470";
    };
    "aarch64-linux" = {
      url = "https://github.com/golang-migrate/migrate/releases/download/v${version}/migrate.linux-arm64.tar.gz";
      sha256 = "1iaihw2yklbb86v20jspb5h726mda74p315ryk1prw7kq1aj9sig";
    };
    "x86_64-linux" = {
      url = "https://github.com/golang-migrate/migrate/releases/download/v${version}/migrate.linux-amd64.tar.gz";
      sha256 = "066fqzsccc1nax8gqy93w9qqy5qjcbwkrcx7nndbc9xis7xliiia";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  src = sources.${system} or (throw "Unsupported system: ${system}");
in
pkgs.stdenv.mkDerivation {
  pname = "go-migrate";
  inherit version;

  src = pkgs.fetchurl {
    inherit (src) url sha256;
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp migrate $out/bin/migrate
    chmod +x $out/bin/migrate
  '';

  meta = with pkgs.lib; {
    description = "Database migrations written in Go, for CLI and as a library";
    homepage = "https://github.com/golang-migrate/migrate";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "migrate";
  };
}
