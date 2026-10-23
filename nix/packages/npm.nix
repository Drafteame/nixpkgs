{ pkgs, node }:

let
  inherit (pkgs) lib;

  # npm bundled in the pinned node release (see node.nix); bump together.
  version = "11.20.0";

  # Setup hooks run while the environment is built (HOME=/homeless-shelter) and
  # `nix develop` restores the real HOME afterwards, so the PATH update is also
  # appended to shellHook, which runs once the user's shell has started.
  npmGlobalPathHook = pkgs.writeText "npm-global-path-hook.sh" ''
    _draftea_npm_global_path() {
      if [ -n "''${HOME:-}" ] && [ "$HOME" != /homeless-shelter ]; then
        local bin="''${NPM_CONFIG_PREFIX:-''${npm_config_prefix:-$HOME/.npm-global}}/bin"
        case ":$PATH:" in
          *":$bin:"*) ;;
          *) export PATH="$PATH:$bin" ;;
        esac
      fi
    }
    _draftea_npm_global_path
    shellHook="''${shellHook:-}"$'\n_draftea_npm_global_path\n'
  '';
in
pkgs.stdenv.mkDerivation {
  pname = "npm";
  inherit version;

  # Same official node tarball, so there is no extra hash to maintain.
  inherit (node) src;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchShebangs = true;

  # The builtin npmrc sits at the lowest priority, so --prefix,
  # NPM_CONFIG_PREFIX, project .npmrc and ~/.npmrc all still override it.
  # npm expands ${HOME} itself.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules $out/bin
    cp -R lib/node_modules/npm $out/lib/node_modules/npm
    echo 'prefix=''${HOME}/.npm-global' > $out/lib/node_modules/npm/npmrc

    for c in npm npx; do
      makeWrapper ${node}/bin/node $out/bin/$c \
        --add-flags $out/lib/node_modules/npm/bin/$c-cli.js \
        --suffix PATH : ${node}/bin
    done

    mkdir -p $out/nix-support
    cp ${npmGlobalPathHook} $out/nix-support/setup-hook

    runHook postInstall
  '';

  meta = with lib; {
    description = "npm package manager (bundled with the pinned node release), global installs under $HOME/.npm-global";
    homepage = "https://www.npmjs.com";
    license = licenses.artistic2;
    inherit (node.meta) platforms;
    mainProgram = "npm";
  };
}
