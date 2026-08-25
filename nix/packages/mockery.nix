{ pkgs }:

let
  version = "3.7.4";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/vektra/mockery/releases/download/v${version}/mockery_${version}_Darwin_arm64.tar.gz";
      sha256 = "0y2g20z2gkpr69vgm2f4g02n1vfqz8kxc77192fn4dnqp5dky16p";
    };
    "x86_64-darwin" = {
      url = "https://github.com/vektra/mockery/releases/download/v${version}/mockery_${version}_Darwin_x86_64.tar.gz";
      sha256 = "1pskh16pp1qgb03g3c75qk6m0vqcv25nzxvwg3x12p437niahnr8";
    };
    "aarch64-linux" = {
      url = "https://github.com/vektra/mockery/releases/download/v${version}/mockery_${version}_Linux_arm64.tar.gz";
      sha256 = "0jvchbzr9c96mm5sngvix41d0j37mld4b3sbxqynr9xdyng1yngy";
    };
    "x86_64-linux" = {
      url = "https://github.com/vektra/mockery/releases/download/v${version}/mockery_${version}_Linux_x86_64.tar.gz";
      sha256 = "0dvk1wpvzqwpcly16a01ggzzr2vah88kiadmiavn4hla4cpgbvnm";
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
