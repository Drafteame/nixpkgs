{ pkgs }:

let
  inherit (pkgs) lib;
  version = "3.14.9";
  release = "20261021";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-aarch64-apple-darwin-install_only.tar.gz";
      sha256 = "0sp3amvm17rwjlx75ga4dmd5gc8rqfqmbcnmnh1kv9d889k6jv92";
    };
    "x86_64-darwin" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-x86_64-apple-darwin-install_only.tar.gz";
      sha256 = "18l70kzy8j57yififr39a5dmav55103zs54265r7qzh0vlvg6330";
    };
    "aarch64-linux" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-aarch64-unknown-linux-gnu-install_only.tar.gz";
      sha256 = "0cp7k4ma3iimbjxwgr8sk7mq5qfph8i1kc3v409b0h3lfax9ay44";
    };
    "x86_64-linux" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-x86_64-unknown-linux-gnu-install_only.tar.gz";
      sha256 = "1pxba62bqgm09pxb3gz6j71lf8n7a3jpn0aq2vs3iws71jjcb96z";
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
