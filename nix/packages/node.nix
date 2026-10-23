{ pkgs }:

let
  inherit (pkgs) lib;
  version = "26.12.1";

  # sha256 hashes come from https://nodejs.org/dist/v${version}/SHASUMS256.txt
  # (hex is accepted by fetchurl as-is).
  platforms = {
    "aarch64-darwin" = {
      suffix = "darwin-arm64";
      sha256 = "1901d539912c02afa10d1cc126943a8855a7eedebe830119463470db5e6c59e8";
    };
    "x86_64-darwin" = {
      suffix = "darwin-x64";
      sha256 = "b85c2ea4420ad0bc4abf2dc6cf1f55130ed681f1cabf60cf3f526e4c9e2712ff";
    };
    "aarch64-linux" = {
      suffix = "linux-arm64";
      sha256 = "a6c01af459dd8972ab3fb08ee5da81244d26ba8c4944a62d5bbba8c597ae154f";
    };
    "x86_64-linux" = {
      suffix = "linux-x64";
      sha256 = "0fd1eb7770598f52a21995edf6ed35fc690400fa437c2386af329519e9143132";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  platform = platforms.${system}
    or (throw "node.nix: unsupported system ${system}");
in
pkgs.stdenv.mkDerivation {
  pname = "node";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://nodejs.org/dist/v${version}/node-v${version}-${platform.suffix}.tar.gz";
    inherit (platform) sha256;
  };

  nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.autoPatchelfHook
  ];

  buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchShebangs = true;

  # npm, npx and corepack are dropped on purpose: the `npm` and `pnpm`
  # packages provide the package managers so they stay optional.
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R . $out/
    rm -rf $out/bin/npm $out/bin/npx $out/bin/corepack \
           $out/lib/node_modules/npm $out/lib/node_modules/corepack
    rmdir $out/lib/node_modules $out/lib 2>/dev/null || true

    runHook postInstall
  '';

  meta = with lib; {
    description = "Node.js JavaScript runtime (pinned official binary release, without npm)";
    homepage = "https://nodejs.org";
    license = licenses.mit;
    platforms = builtins.attrNames platforms;
    mainProgram = "node";
  };
}
