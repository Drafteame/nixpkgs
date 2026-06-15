{
  description = "Draftea custom Nix derivations (go, python, ejson, pkl, golang-migrate, ...)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Re-exported so the release workflow can use backend-ci's `ci-deploy`
    # devshell (which pins commitizen + git) via this repo's flake. Pinned
    # to a tag so `cz-bump`'s behavior is reproducible.
    backend-ci.url = "git+ssh://git@github.com/Drafteame/backend-ci?ref=refs/tags/v0.8.0";
    backend-ci.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        ./nix/overlays
        ./nix/packages
        ./nix/shells
        ./nix/checks
      ];
    };
}
