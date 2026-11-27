{ pkgs }:

# modcheck (Go dependency vulnerability and maintenance scanner) pinned to the
# official prebuilt release.
#
# The upstream flake builds modcheck from source with buildGoModule, so every
# machine downloads the Go modules and compiles it. The release ships the same
# binary built by goreleaser for the four supported systems.
#
# To refresh, take the sha256 of each tarball from the release's checksums.txt
# (https://github.com/Drafteame/modcheck/releases) and convert it:
#   nix hash convert --hash-algo sha256 --to sri <hex>
# and bump expectedVersion in nix/checks/modcheck.nix.
let
  version = "0.2.1";

  sources = {
    "aarch64-darwin" = {
      suffix = "Darwin_arm64";
      hash = "sha256-ZlW3eKMwU2beNI951Xaa0CVIDzW+k925JfY1fmFdirk=";
    };
    "x86_64-darwin" = {
      suffix = "Darwin_x86_64";
      hash = "sha256-N8XG7ZnA2xgGQb8RUlKK+wIQCpBa2INl6iE0H1JlZjo=";
    };
    "aarch64-linux" = {
      suffix = "Linux_arm64";
      hash = "sha256-TG49lStDQhEemmgx0zOu9/04ljpt2/Q8yQQlu4LinjA=";
    };
    "x86_64-linux" = {
      suffix = "Linux_x86_64";
      hash = "sha256-xrm3IMsoViWqDWtUUVpWgI3nDTLQbXFYJxQbZsrDTNk=";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  source = sources.${system} or (throw "Unsupported system: ${system}");
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "modcheck";
  inherit version;

  # The release asset names carry no version; the tag in the URL pins it.
  src = pkgs.fetchurl {
    url = "https://github.com/Drafteame/modcheck/releases/download/v${version}/modcheck_${source.suffix}.tar.gz";
    inherit (source) hash;
  };

  # The tarball is flat: CHANGELOG.md, LICENSE, README.md and the binary.
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 modcheck $out/bin/modcheck

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Check Go dependencies for vulnerabilities and maintenance health (official prebuilt release)";
    homepage = "https://github.com/Drafteame/modcheck";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "modcheck";
  };
}
