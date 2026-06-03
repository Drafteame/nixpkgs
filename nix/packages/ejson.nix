{ pkgs }:

let
  version = "1.5.4";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_darwin_arm64.tar.gz";
      sha256 = "02jysv1smzfj9lasdh3ix7irnqqszbqbxw38ld14r2s49n4dxlrz";
    };
    "x86_64-darwin" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_darwin_amd64.tar.gz";
      sha256 = "1jqm0qvk34pchhnigpalc54cpw0n01nkrygmynhqkka580dr5mas";
    };
    "aarch64-linux" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_linux_arm64.tar.gz";
      sha256 = "0i3vhjhin56zsm2kmrmsakqy00f5wjcaj1ddx4zbcpbyxgxdp4dr";
    };
    "x86_64-linux" = {
      url = "https://github.com/Shopify/ejson/releases/download/v${version}/ejson_${version}_linux_amd64.tar.gz";
      sha256 = "1visghrhaamnw53512i0117spsi14dyjgr4kcksl3kgkyh631f1b";
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
