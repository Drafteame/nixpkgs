{ pkgs, ... }:

let
  inherit (pkgs) lib;
  version = "1.26.4";

  # Platform-specific SRI hashes for the official prebuilt tarball from
  # https://go.dev/dl/. To refresh, run:
  #   nix-prefetch-url --type sha256 https://go.dev/dl/go${version}.${suffix}.tar.gz
  #   nix hash convert --hash-algo sha256 --to sri <base32>
  platforms = {
    "aarch64-darwin" = {
      suffix = "darwin-arm64";
      hash = "sha256-tirSttfSRk8Spbytf/R/GdCDJXc7Xv0hYQ5EWgWpv1M=";
    };
    "x86_64-darwin" = {
      suffix = "darwin-amd64";
      hash = "sha256-BdybX5mXdEUgquuz1d6qfHVTca67+3+XwlEanzNnU40=";
    };
    "aarch64-linux" = {
      suffix = "linux-arm64";
      hash = "sha256-73WK58bPkmfJwO8IC4ll9FPYmrLSXZ6yLeRAWSUjh2g=";
    };
    "x86_64-linux" = {
      suffix = "linux-amd64";
      hash = "sha256-EVPT1Q4Kx2S0R63+BcK88I6InUKgLg/gJZvUf2czrX8=";
    };
  };

  system = pkgs.stdenv.hostPlatform.system;
  platform = platforms.${system}
    or (throw "go.nix: unsupported system ${system}");
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "go";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://go.dev/dl/go${version}.${platform.suffix}.tar.gz";
    inherit (platform) hash;
  };

  dontConfigure = true;
  dontBuild = true;
  dontPatchShebangs = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/go
    cp -R . $out/share/go/

    mkdir -p $out/bin
    for bin in go gofmt; do
      ln -s $out/share/go/bin/$bin $out/bin/$bin
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "The Go programming language (pinned official binary release)";
    homepage = "https://go.dev";
    license = licenses.bsd3;
    platforms = builtins.attrNames platforms;
  };
}
