{ pkgs }:

# goimports-reviser pinned to the official prebuilt release.
#
# The nixpkgs package lags (3.12.6 on nixos-26.05) and its standard-library
# package list is hardcoded: it lacks packages added in recent Go releases (for
# example encoding/json/jsontext), so a file importing them is reported as badly
# formatted while a newer tool accepts it. Pinning the release here keeps the
# tool in step with the Go pinned next to it (see go.nix).
#
# To refresh, take the sha256 of each tarball from the release's checksums.txt
# (https://github.com/incu6us/goimports-reviser/releases) and convert it:
#   nix hash convert --hash-algo sha256 --to sri <hex>
# and bump expectedVersion in nix/checks/goimports-reviser.nix.
let
  version = "3.13.2";

  sources = {
    "aarch64-darwin" = {
      suffix = "darwin_arm64";
      hash = "sha256-kNPzYWWb3V+LmFBV+EafiM5uGVv6OWgq+vVrUsW2fPg=";
    };
    "x86_64-darwin" = {
      suffix = "darwin_amd64";
      hash = "sha256-KgOKpGvig8kOdEegPODvfZBI1Db1HcrgucpdrkxZk6Q=";
    };
    "aarch64-linux" = {
      suffix = "linux_arm64";
      hash = "sha256-0Gqru/yaOfFTWYwa/8f64mTN31MUYJYay62Yg97niDQ=";
    };
    "x86_64-linux" = {
      suffix = "linux_amd64";
      hash = "sha256-o1jIAwxV6Vu1Z8jVzMgm/4j4WKFtT7CkqYG9dyyW1Gk=";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  source = sources.${system} or (throw "Unsupported system: ${system}");
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "goimports-reviser";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://github.com/incu6us/goimports-reviser/releases/download/v${version}/goimports-reviser_${version}_${source.suffix}.tar.gz";
    inherit (source) hash;
  };

  # The tarball is flat: LICENSE, README.md and the binary.
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 goimports-reviser $out/bin/goimports-reviser

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Right imports sorting & code formatting tool (official prebuilt release)";
    homepage = "https://github.com/incu6us/goimports-reviser";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "goimports-reviser";
  };
}
