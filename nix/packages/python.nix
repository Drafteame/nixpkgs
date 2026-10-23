{ pkgs }:

let
  inherit (pkgs) lib;
  version = "3.15.1";
  release = "20261021";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-aarch64-apple-darwin-install_only.tar.gz";
      sha256 = "0cczcq57f666bhdv17yhppvg30ljkh66mxj0qgs8bgjg42gc44vq";
    };
    "x86_64-darwin" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-x86_64-apple-darwin-install_only.tar.gz";
      sha256 = "1li3hmw8sgfsfgra59dc2aavjwgs3s4yjvk39z943pryy38bdn47";
    };
    "aarch64-linux" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-aarch64-unknown-linux-gnu-install_only.tar.gz";
      sha256 = "1hbg4kpxqkppm79z69806apj5xwhqqiaj2qvlc8c7rl68x28yqwy";
    };
    "x86_64-linux" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-x86_64-unknown-linux-gnu-install_only.tar.gz";
      sha256 = "045prn0rmsszyrwdkg6wyhn44iiizizsxp1991pw04dnh25mm1v7";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  src = sources.${system} or (throw "python.nix: unsupported system ${system}");
in
pkgs.stdenv.mkDerivation {
  pname = "python";
  inherit version;

  src = pkgs.fetchurl {
    inherit (src) url sha256;
  };

  sourceRoot = "python";

  nativeBuildInputs = lib.optionals pkgs.stdenv.isLinux [
    pkgs.autoPatchelfHook
  ];

  buildInputs = lib.optionals pkgs.stdenv.isLinux [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R . $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Standalone, relocatable CPython distribution (python-build-standalone)";
    homepage = "https://github.com/astral-sh/python-build-standalone";
    license = licenses.psfl;
    platforms = builtins.attrNames sources;
    mainProgram = "python3";
  };
}
