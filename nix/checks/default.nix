_:
{
  perSystem =
    { pkgs, self', ... }:
    {
      # Each check is a derivation that builds only if its assertions pass.
      # Runs via `nix flake check` or `nix build .#checks.<system>.<name>`.
      checks = {
        ejson = import ./ejson.nix { inherit pkgs self'; };
        go = import ./go.nix { inherit pkgs self'; };
        go-migrate = import ./go-migrate.nix { inherit pkgs self'; };
        pkl = import ./pkl.nix { inherit pkgs self'; };
        python = import ./python.nix { inherit pkgs self'; };
      };
    };
}
