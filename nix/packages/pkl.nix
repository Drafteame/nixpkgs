{ pkgs }:

let
  version = "0.31.1";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-macos-aarch64";
      sha256 = "13qfrbkwcin5nshpij75xxrfy9zspcdp4c3mi9wx4k32v4w58shv";
    };
    "x86_64-darwin" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-macos-amd64";
      sha256 = "07a759m3f2lf2inrvc371zxb0fgc1dzzfsacqnlay0scmva3w4i2";
    };
    "aarch64-linux" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-aarch64";
      sha256 = "0gh85lzv3bm2kr5q2m8c4nzn5ww6d7nbkgg79awiz4ma7ms0xwby";
    };
    "x86_64-linux" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-amd64";
      sha256 = "1gri2bdm29wd77yvysmwkpa8r11mfv9a3jy9x2zsyp3mbnai73v1";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  src = sources.${system} or (throw "Unsupported system: ${system}");
in
pkgs.stdenv.mkDerivation {
  pname = "pkl";
  inherit version;

  src = pkgs.fetchurl {
    inherit (src) url sha256;
  };

  dontUnpack = true;

  nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
    pkgs.autoPatchelfHook
  ];

  buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/pkl
    chmod +x $out/bin/pkl
  '';

  meta = with pkgs.lib; {
    description = "A configuration as code language with rich validation and tooling";
    homepage = "https://pkl-lang.org";
    license = licenses.asl20;
    platforms = builtins.attrNames sources;
    mainProgram = "pkl";
  };
}
