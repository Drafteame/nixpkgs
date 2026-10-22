{ pkgs }:

let
  version = "2.15.0";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/golangci/golangci-lint/releases/download/v${version}/golangci-lint-${version}-darwin-arm64.tar.gz";
      sha256 = "1ma7chdipnnbl5vkj2rs6limrgdibkmq3rwppk24da4c3940kr6i";
    };
    "x86_64-darwin" = {
      url = "https://github.com/golangci/golangci-lint/releases/download/v${version}/golangci-lint-${version}-darwin-amd64.tar.gz";
      sha256 = "1f73xkj7xcd757q80bgbfc8nivy59g65sgc2sbg8hpi852d8jyvn";
    };
    "aarch64-linux" = {
      url = "https://github.com/golangci/golangci-lint/releases/download/v${version}/golangci-lint-${version}-linux-arm64.tar.gz";
      sha256 = "1639988rqr0qqdhida5vdxq0sx28zcb9mxn21h3fcpmkd1qg3n5l";
    };
    "x86_64-linux" = {
      url = "https://github.com/golangci/golangci-lint/releases/download/v${version}/golangci-lint-${version}-linux-amd64.tar.gz";
      sha256 = "1smwkqmay8yfzmcikpdbznd8i9sy848npn7qxj6vjd33pykfczwv";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  src = sources.${system} or (throw "Unsupported system: ${system}");
in
pkgs.stdenv.mkDerivation {
  pname = "golangci-lint";
  inherit version;

  src = pkgs.fetchurl {
    inherit (src) url sha256;
  };

  # The tarball unpacks into golangci-lint-<version>-<os>-<arch>/.
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp golangci-lint-*/golangci-lint $out/bin/golangci-lint
    chmod +x $out/bin/golangci-lint
  '';

  meta = with pkgs.lib; {
    description = "Fast linters runner for Go (official prebuilt release, built with the current Go)";
    homepage = "https://github.com/golangci/golangci-lint";
    license = licenses.gpl3Only;
    platforms = builtins.attrNames sources;
    mainProgram = "golangci-lint";
  };
}
