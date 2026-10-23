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
        golangci-lint = import ./golangci-lint.nix { inherit pkgs self'; };
        mockery = import ./mockery.nix { inherit pkgs self'; };
        node = import ./node.nix { inherit pkgs self'; };
        npm = import ./npm.nix { inherit pkgs self'; };
        pkl = import ./pkl.nix { inherit pkgs self'; };
        pnpm = import ./pnpm.nix { inherit pkgs self'; };
        python = import ./python.nix { inherit pkgs self'; };
        staticcheck = import ./staticcheck.nix { inherit pkgs self'; };
      };
    };
}
