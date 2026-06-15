{ pkgs }:

# Local development shell for working on derivations in this repo.
# Provides Nix linters/formatters, markdown/yaml/shell checkers, and the
# pre-commit framework. The shellHook installs the pre-commit hooks.

let
  preCommitInstall = builtins.readFile ./scripts/pre-commit-install.sh;
in
pkgs.mkShell {
  name = "nixpkgs-dev";

  buildInputs = with pkgs; [
    # Nix tooling
    nixpkgs-fmt
    statix
    deadnix

    # Shell tooling
    shellcheck
    shfmt

    # Markdown / YAML
    markdownlint-cli2
    yamllint

    # Secrets / commit hygiene
    gitleaks
    pre-commit
    commitizen
  ];

  shellHook = preCommitInstall;
}
