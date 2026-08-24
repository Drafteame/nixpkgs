{ pkgs }:

let
  version = "0.32.1";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-macos-aarch64";
      sha256 = "1lyrq75dg84n4rr2c88z7189gvbmqr2xfkj64lv6mc90k8fbagjn";
    };
    "x86_64-darwin" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-macos-amd64";
      sha256 = "07rdgv95xbnjj7nmb0cfp7cnglhjvpmjqvzn8h0rcis04c1vjx2v";
    };
    "aarch64-linux" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-aarch64";
      sha256 = "0n50vc8dzf10dn2gyxgvakm5jzkwyirp6d5h27wshdd4gpa2svd7";
    };
    "x86_64-linux" = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-amd64";
      sha256 = "049jbzpg27xr9ccm67n22cj07yd8yk2vd6sfj0fss32wm4nvd01i";
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
