{
  description = "Draftea custom Nix derivations (go, python, ejson, pkl, golang-migrate, ...)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
