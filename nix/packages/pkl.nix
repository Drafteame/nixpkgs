{ pkgs }:

let
  version = "0.32.2";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-macos-aarch64";
      sha256 = "1scqpv7l18m031m96g0y57j7r4ara5lv79ckcfixz4qcngq54sa6";
    };
    "x86_64-darwin" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-macos-amd64";
      sha256 = "1vkyf62fh8bjqnz201xnh4p877vz8j6ll2vlj8r3y391fm592k1w";
    };
    "aarch64-linux" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-aarch64";
      sha256 = "1qrajs6vxgngrhbq71jyd9fpnf4qby5rjq2jldbh5p2dgphl81z6";
    };
    "x86_64-linux" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-amd64";
      sha256 = "1vrxs3sjsyj5ym5qj1xpbyiywxc85sms8viln9zxgbbr9i47ak47";
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
