{ pkgs, node }:

let
  inherit (pkgs) lib;
  version = "12.15.0";

  # sha256 hashes come from the GitHub release asset digests:
  #   gh api repos/pnpm/pnpm/releases/tags/v${version} --jq '.assets[] | .name + " " + .digest'
  # (hex is accepted by fetchurl as-is).
  platforms = {
    "aarch64-darwin" = {
      suffix = "darwin-arm64";
      sha256 = "6a41a2877773e97f19832067187cc6fc82e186d8a2cf91fec4b4c1a5fbd6ef27";
    };
    "x86_64-darwin" = {
      suffix = "darwin-x64";
      sha256 = "2d7b336884574aee8a765bee48591212e9caf4fcf985fb3279588c1fb73fb47f";
    };
    "aarch64-linux" = {
      suffix = "linux-arm64";
      sha256 = "d7ce93a2c7d847d3a34bd3f559b60c14f578b1320c17cc352a2c5c5fdf956117";
    };
    "x86_64-linux" = {
      suffix = "linux-x64";
      sha256 = "55b5ed0092bd11176c1669598e231ae52e7cedac59de6efd0d415730f37d0598";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  platform = platforms.${system}
    or (throw "pnpm.nix: unsupported system ${system}");

  # Setup hooks run while the environment is built (HOME=/homeless-shelter) and
  # `nix develop` restores the real HOME afterwards, so the PATH update is also
  # appended to shellHook, which runs once the user's shell has started.
  pnpmGlobalPathHook = pkgs.writeText "pnpm-global-path-hook.sh" ''
    _draftea_pnpm_global_path() {
      if [ -n "''${HOME:-}" ] && [ "$HOME" != /homeless-shelter ]; then
        local bin="''${PNPM_HOME:-$HOME/.pnpm-global}/bin"
        case ":$PATH:" in
          *":$bin:"*) ;;
          *) export PATH="$PATH:$bin" ;;
        esac
      fi
    }
    _draftea_pnpm_global_path
    shellHook="''${shellHook:-}"$'\n_draftea_pnpm_global_path\n'
  '';
in
pkgs.stdenv.mkDerivation {
  pname = "pnpm";
  inherit version;

  # The standalone release is a native executable plus a dist/ directory; the
  # registry package is only a placeholder that fetches the binary on install.
  src = pkgs.fetchurl {
    url = "https://github.com/pnpm/pnpm/releases/download/v${version}/pnpm-${platform.suffix}.tar.gz";
    inherit (platform) sha256;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ pkgs.makeWrapper ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];

  buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchShebangs = true;

  # pnpm has no builtin config file, so the wrapper defaults PNPM_HOME to
  # $HOME/.pnpm-global (only when unset), creates it and puts its bin/ on
  # PATH because `pnpm add -g` refuses to run when the global bin dir
  # ($PNPM_HOME/bin) is missing from PATH. node stays on PATH so lifecycle
  # scripts and node-gyp work.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/pnpm $out/bin
    cp -R pnpm dist $out/lib/pnpm/

    makeWrapper $out/lib/pnpm/pnpm $out/bin/pnpm \
      --suffix PATH : ${node}/bin \
      --run 'if [ -z "''${PNPM_HOME:-}" ] && [ -n "''${HOME:-}" ]; then export PNPM_HOME="$HOME/.pnpm-global"; fi' \
      --run 'if [ -n "''${PNPM_HOME:-}" ]; then mkdir -p "$PNPM_HOME/bin" 2>/dev/null || true; case ":$PATH:" in *":$PNPM_HOME/bin:"*) ;; *) export PATH="$PATH:$PNPM_HOME/bin";; esac; fi'

    mkdir -p $out/nix-support
    cp ${pnpmGlobalPathHook} $out/nix-support/setup-hook

    runHook postInstall
  '';

  meta = with lib; {
    description = "Fast, disk space efficient package manager, global installs under $HOME/.pnpm-global";
    homepage = "https://pnpm.io";
    license = licenses.mit;
    inherit (node.meta) platforms;
    mainProgram = "pnpm";
  };
}
