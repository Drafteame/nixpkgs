{ pkgs }:

# draft (Drafteame's framework CLI) pinned to the official prebuilt release.
#
# The upstream flake builds draft from source with buildGoModule, so every
# machine downloads the Go modules and compiles it. The release ships the same
# binary built by goreleaser for the four supported systems.
#
# To refresh, take the sha256 of each tarball from the release's checksums.txt
# (https://github.com/Drafteame/draft/releases) and convert it:
#   nix hash convert --hash-algo sha256 --to sri <hex>
# and bump expectedVersion in nix/checks/draft.nix.
let
  version = "1.28.0";

  sources = {
    "aarch64-darwin" = {
      suffix = "darwin_arm64";
      hash = "sha256-zZyPfJtgSf2QN9A0My2l0yLwi6VULxs0yYyesxjMTfg=";
    };
    "x86_64-darwin" = {
      suffix = "darwin_amd64";
      hash = "sha256-HkZCBav9bY52vThUMJAjx19ocuriBQL6BVed6NuR4OM=";
    };
    "aarch64-linux" = {
      suffix = "linux_arm64";
      hash = "sha256-V0+XekcqIsMrZVZgbx5871wRJpz6QeXBe4AFnECJJZY=";
    };
    "x86_64-linux" = {
      suffix = "linux_amd64";
      hash = "sha256-FdWJA7WPjiO4Xw42ixhxcx2QOC/9DQxlOxYtQ0fuQmY=";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  source = sources.${system} or (throw "Unsupported system: ${system}");
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "draft";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://github.com/Drafteame/draft/releases/download/v${version}/draft_${source.suffix}_${version}.tar.gz";
    inherit (source) hash;
  };

  # The tarball is flat: CHANGELOG.md, LICENSE, README.md and the binary.
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 draft $out/bin/draft

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "CLI tool to use the Drafteame framework (official prebuilt release)";
    homepage = "https://github.com/Drafteame/draft";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "draft";
  };
}
