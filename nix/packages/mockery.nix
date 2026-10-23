{ pkgs }:

let
  version = "3.8.1";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/vektra/mockery/releases/download/v${version}/mockery_${version}_Darwin_arm64.tar.gz";
      sha256 = "0d2h5lxdasrf6yqxf41fihkr9gvlz5b71hx0gnrhcf94hi27jfih";
    };
    "x86_64-darwin" = {
      url = "https://github.com/vektra/mockery/releases/download/v${version}/mockery_${version}_Darwin_x86_64.tar.gz";
      sha256 = "0vya6balkglapq9n8lwnm09h46ip04mh9kjd625jcip98h9k70k8";
    };
    "aarch64-linux" = {
      url = "https://github.com/vektra/mockery/releases/download/v${version}/mockery_${version}_Linux_arm64.tar.gz";
      sha256 = "0lpljqv9a4aqinahhxfxlnrrl47f7192dnk5mp9qv1p9lvrq3x6i";
    };
    "x86_64-linux" = {
      url = "https://github.com/vektra/mockery/releases/download/v${version}/mockery_${version}_Linux_x86_64.tar.gz";
      sha256 = "0ap759nyh971s82c8j9vffdpxwmvz352fpsr3j5kkmldnlw7sg4m";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  src = sources.${system} or (throw "Unsupported system: ${system}");
in
pkgs.stdenv.mkDerivation {
  pname = "mockery";
  inherit version;

  src = pkgs.fetchurl {
    inherit (src) url sha256;
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp mockery $out/bin/mockery
    chmod +x $out/bin/mockery
  '';

  meta = with pkgs.lib; {
    description = "Mock code autogenerator for Go interfaces";
    homepage = "https://github.com/vektra/mockery";
    license = licenses.bsd3;
    platforms = builtins.attrNames sources;
    mainProgram = "mockery";
  };
}
