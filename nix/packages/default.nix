_:
{
  perSystem =
    { pkgs, ... }:
    let
      node = import ./node.nix { inherit pkgs; };
    in
    {
      packages = {
        ejson = import ./ejson.nix { inherit pkgs; };
        go = import ./go.nix { inherit pkgs; };
        go-migrate = import ./go-migrate.nix { inherit pkgs; };
        golangci-lint = import ./golangci-lint.nix { inherit pkgs; };
        mockery = import ./mockery.nix { inherit pkgs; };
        inherit node;
        npm = import ./npm.nix { inherit pkgs node; };
        pkl = import ./pkl.nix { inherit pkgs; };
        pnpm = import ./pnpm.nix { inherit pkgs node; };
        python = import ./python.nix { inherit pkgs; };
        staticcheck = import ./staticcheck.nix { inherit pkgs; };
      };
    };
}
