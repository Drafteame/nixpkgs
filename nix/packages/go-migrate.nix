{ pkgs }:

let
  version = "4.20.1";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/golang-migrate/migrate/releases/download/v${version}/migrate.darwin-arm64.tar.gz";
      sha256 = "1hh64mjz66dm3w8q59v30qd42l8w9jirkvzh529xmgmn3vj8fvyn";
    };
    "x86_64-darwin" = {
      url = "https://github.com/golang-migrate/migrate/releases/download/v${version}/migrate.darwin-amd64.tar.gz";
      sha256 = "12gfbysg9swv1wjafyfi7gagvv39fymbbbjyk3i5msmzdxsw7dxc";
    };
    "aarch64-linux" = {
      url = "https://github.com/golang-migrate/migrate/releases/download/v${version}/migrate.linux-arm64.tar.gz";
      sha256 = "0q4g9ffhw1x8idsa7g1gzb87qmkahp8j08b00gz6hnskpbcp1sh3";
    };
    "x86_64-linux" = {
      url = "https://github.com/golang-migrate/migrate/releases/download/v${version}/migrate.linux-amd64.tar.gz";
      sha256 = "1m0v5qcrnpnn5hzy6nky1wwk5dsp5nkdqagvm427i2qpshhk3qdi";
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
