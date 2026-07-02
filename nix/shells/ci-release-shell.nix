{ pkgs }:

pkgs.mkShell {
  name = "ci-release";

  buildInputs = with pkgs; [
    commitizen
    git
  ];
}
