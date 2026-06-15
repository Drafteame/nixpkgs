{ pkgs }:

let
  inherit (pkgs) lib;
  version = "3.14.5";
  release = "20260602";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-aarch64-apple-darwin-install_only.tar.gz";
      sha256 = "09ww67gpc9j3l1xf0i3mkq3ibia14d0l9xgkq0b5v7iaasdrq8gk";
    };
    "x86_64-darwin" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-x86_64-apple-darwin-install_only.tar.gz";
      sha256 = "1yx9gnbv85fwbnm9qdrm7siac6mcfl22dl10hs6qzk6wsrz8hddf";
    };
    "aarch64-linux" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-aarch64-unknown-linux-gnu-install_only.tar.gz";
      sha256 = "0pmfwsd345v5h43jjqsjnqpv9bpi21nrirlq6ff30105232wqxn2";
    };
    "x86_64-linux" = {
      url = "https://github.com/astral-sh/python-build-standalone/releases/download/${release}/cpython-${version}+${release}-x86_64-unknown-linux-gnu-install_only.tar.gz";
      sha256 = "13ykql2kcwk717rs26pwaqf6i4sn4rq31yidb87430izbrhc2b4n";
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
