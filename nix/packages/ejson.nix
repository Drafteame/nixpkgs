{ pkgs }:

let
  version = "1.6.0";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_darwin_arm64.tar.gz";
      sha256 = "0rql809dn8a24z1bqdvg0ggalxhr42qjpiap8dpy9s19qzdwjhyd";
    };
    "x86_64-darwin" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_darwin_amd64.tar.gz";
      sha256 = "052g7csnbqy0x97g8374cin9g4qd52pn2db6y7y2f2k1d46czfa9";
    };
    "aarch64-linux" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_linux_arm64.tar.gz";
      sha256 = "0sxhs3a645bkwjvjvb1yrir6icm2w3w3yyznyaij5kdnjqnfg0sz";
    };
    "x86_64-linux" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_linux_amd64.tar.gz";
      sha256 = "08zhpkpd1wk2p7bz0dfh7r7m1wshaxhml8389bb2djsvq3h1fk9m";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  src = sources.${system} or (throw "Unsupported system: ${system}");
in
pkgs.stdenv.mkDerivation {
  pname = "ejson";
  inherit version;

  src = pkgs.fetchurl {
    inherit (src) url sha256;
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp ejson $out/bin/ejson
    chmod +x $out/bin/ejson
  '';

  meta = with pkgs.lib; {
    description = "Asymmetric keywise encryption for JSON";
    homepage = "https://github.com/Shopify/ejson";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "ejson";
  };
}
