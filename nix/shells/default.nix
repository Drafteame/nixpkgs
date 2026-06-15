{ inputs, ... }:

{
  perSystem =
    { pkgs
    , system
    , ...
    }:
    let
      dev = import ./dev-shell.nix { inherit pkgs; };
    in
    {
      devShells = {
        # Local development — Nix lint/format tooling plus the pre-commit
        # framework. Entered automatically by direnv.
        default = dev;
        inherit dev;

        # Re-exported from backend-ci so the release workflow can run
        # commitizen against this repo without re-implementing the shell
        # locally. Used by the `cz-bump` composite action.
        ci-deploy = inputs.backend-ci.devShells.${system}.ci-deploy;
      };
    };
}
