_:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        ejson = import ./ejson.nix { inherit pkgs; };
        go = import ./go.nix { inherit pkgs; };
        go-migrate = import ./go-migrate.nix { inherit pkgs; };
        pkl = import ./pkl.nix { inherit pkgs; };
        python = import ./python.nix { inherit pkgs; };
      };
    };
}
