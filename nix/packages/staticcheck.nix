{ pkgs }:

let
  version = "2026.2.2";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/dominikh/go-tools/releases/download/${version}/staticcheck_darwin_arm64.tar.gz";
      sha256 = "05sl6qs3qhidx560n3qznk68jjqhyrq8gv1iblbnhmhzarzvym60";
    };
    "x86_64-darwin" = {
      url = "https://github.com/dominikh/go-tools/releases/download/${version}/staticcheck_darwin_amd64.tar.gz";
      sha256 = "0dpq3l7r6362zl8460hkfh1zc01hsra2wbn35iijqhv9c26y8320";
    };
    "aarch64-linux" = {
      url = "https://github.com/dominikh/go-tools/releases/download/${version}/staticcheck_linux_arm64.tar.gz";
      sha256 = "0ibh5xz3g9vkrb8qq1nb8bq2zq497gp13y33c1m29srp3kwamgfc";
    };
    "x86_64-linux" = {
      url = "https://github.com/dominikh/go-tools/releases/download/${version}/staticcheck_linux_amd64.tar.gz";
      sha256 = "0p5asclfhkh2r7pmyih10p9gjnjaglskvzak9i6mlnyhy3h83h0l";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  src = sources.${system} or (throw "Unsupported system: ${system}");
in
pkgs.stdenv.mkDerivation {
  pname = "staticcheck";
  inherit version;

  src = pkgs.fetchurl {
    inherit (src) url sha256;
  };

  # The tarball unpacks into staticcheck/.
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp staticcheck/staticcheck $out/bin/staticcheck
    chmod +x $out/bin/staticcheck
  '';

  meta = with pkgs.lib; {
    description = "Go static analysis (official prebuilt release, built with the current Go)";
    homepage = "https://staticcheck.dev";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "staticcheck";
  };
}
