_:

{
  perSystem =
    { pkgs
    , ...
    }:
    let
      dev = import ./dev-shell.nix { inherit pkgs; };
      ciRelease = import ./ci-release-shell.nix { inherit pkgs; };
    in
    {
      devShells = {
        default = dev;
        inherit dev;
        ci-release = ciRelease;
      };
    };
}
