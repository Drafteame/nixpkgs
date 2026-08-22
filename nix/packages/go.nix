{ pkgs, ... }:

let
  inherit (pkgs) lib;
  version = "1.27.0";

  # Platform-specific SRI hashes for the official prebuilt tarball from
  # https://go.dev/dl/. To refresh, run:
  #   nix-prefetch-url --type sha256 https://go.dev/dl/go${version}.${suffix}.tar.gz
  #   nix hash convert --hash-algo sha256 --to sri <base32>
  platforms = {
    "aarch64-darwin" = {
      suffix = "darwin-arm64";
      hash = "sha256-kEk7O71eEPkdEhUxmL8ZlP11Y5m0/sk7SbDG4qze6z4=";
    };
    "x86_64-darwin" = {
      suffix = "darwin-amd64";
      hash = "sha256-0zFOJUluQ4HXGlxR0pB+evZV0Zn2eAtUnwFb2F/vSYY=";
    };
    "aarch64-linux" = {
      suffix = "linux-arm64";
      hash = "sha256-UXmNLELQ4cbtf9n0hyi0GTq6yeiq1tusL+lqgfWQm9o=";
    };
    "x86_64-linux" = {
      suffix = "linux-amd64";
      hash = "sha256-Z1wmxEnLsY/CS3RlDeHqu65uFvZDJv2FooP7O1goBoU=";
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
