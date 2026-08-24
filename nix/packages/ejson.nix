{ pkgs }:

let
  version = "1.5.5";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_darwin_arm64.tar.gz";
      sha256 = "1y417iyqvzb2ywwpk4qjab6da7nkqb1kn9hh7vz9plismzzr4mj7";
    };
    "x86_64-darwin" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_darwin_amd64.tar.gz";
      sha256 = "01rviq7vsiyf7d4zbp7laschaq9nz5vc05l49h1k64jdkplrxcnl";
    };
    "aarch64-linux" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_linux_arm64.tar.gz";
      sha256 = "1qnyd2m159iw888n27qv6ikf3hd38hs5n04mqcchk93qd2az41zy";
    };
    "x86_64-linux" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_linux_amd64.tar.gz";
      sha256 = "1ihdab0cwh9kffvlq12b33n7449v8bv8f8wsw7vpk0ca98ssjgnd";
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
