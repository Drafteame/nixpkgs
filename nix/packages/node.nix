{ pkgs }:

let
  inherit (pkgs) lib;
  version = "24.22.2";

  # sha256 hashes come from https://nodejs.org/dist/v${version}/SHASUMS256.txt
  # (hex is accepted by fetchurl as-is).
  platforms = {
    "aarch64-darwin" = {
      suffix = "darwin-arm64";
      sha256 = "aa9549349e47dffaa42dcf95d6e06ade8c4bdafc980979883b88767670df385a";
    };
    "x86_64-darwin" = {
      suffix = "darwin-x64";
      sha256 = "d5e336d588c45be0c37dbd52cc29895593009ca4997a77a1fd02815131ed0e52";
    };
    "aarch64-linux" = {
      suffix = "linux-arm64";
      sha256 = "95c264150aceb7f3437a29fd6984924f5f8d1511ea3cbd6c508b83f6c555dae2";
    };
    "x86_64-linux" = {
      suffix = "linux-x64";
      sha256 = "361718c444e49af2ca5a110c83ba6a8901143f23ab285ebbef0341f391f482a9";
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
