# nixpkgs

Custom Nix derivations for tools (`go`, `python`, `ejson`, `pkl`, `golang-migrate`, `mockery`, `golangci-lint`, `staticcheck`, `node`, `npm`, `pnpm`, ...) consumable from
[flake-parts](https://flake.parts/), [devenv](https://devenv.sh/), and other Nix-based setups.

Each derivation pins a single upstream version and ships prebuilt binaries from the official release
channel for the four supported systems: `aarch64-darwin`, `x86_64-darwin`, `aarch64-linux`,
`x86_64-linux`. The goal is reproducible, version-locked toolchains across Draftea repositories
without committing build artifacts or trusting drift in upstream channels.

## Available packages

| Package      | Version  | Source                                                                       |
| ------------ | -------- | ---------------------------------------------------------------------------- |
| `ejson`      | 1.6.0    | [Shopify/ejson](https://github.com/Shopify/ejson)                            |
| `go`         | 1.27.3   | [go.dev/dl](https://go.dev/dl)                                               |
| `go-migrate` | 4.20.1   | [golang-migrate/migrate](https://github.com/golang-migrate/migrate)          |
| `golangci-lint` | 2.15.0 | [golangci/golangci-lint](https://github.com/golangci/golangci-lint) |
| `mockery`    | 3.8.1    | [vektra/mockery](https://github.com/vektra/mockery)                          |
| `node`       | 26.12.1  | [nodejs.org/dist](https://nodejs.org/dist)                                   |
| `npm`        | 11.20.0  | [npm/cli](https://github.com/npm/cli) (the copy bundled in the pinned Node release) |
| `pkl`        | 0.32.2   | [apple/pkl](https://github.com/apple/pkl)                                    |
| `pnpm`       | 12.15.0  | [pnpm/pnpm](https://github.com/pnpm/pnpm)                                    |
| `python`     | 3.15.1   | [astral-sh/python-build-standalone](https://github.com/astral-sh/python-build-standalone) |
| `staticcheck` | 2026.2.2 | [dominikh/go-tools](https://github.com/dominikh/go-tools) |

## Consuming from another flake

Add this repo as an input and reference the package you need by name.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    draftea-pkgs.url = "github:Drafteame/nixpkgs";
    draftea-pkgs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" "x86_64-linux" ];

      perSystem =
        { pkgs, system, ... }:
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [
              inputs.draftea-pkgs.packages.${system}.go
              inputs.draftea-pkgs.packages.${system}.pkl
              inputs.draftea-pkgs.packages.${system}.ejson
            ];
          };
        };
    };
}
```

Pin to a specific tag (`github:Drafteame/nixpkgs/v0.1.0`) when you need reproducibility across
machines and CI.

### Consuming from devenv

```nix
{ inputs, pkgs, ... }:

{
  packages = [
    inputs.draftea-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.go
    inputs.draftea-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.python
  ];
}
```

## Node, npm and pnpm

`node`, `npm` and `pnpm` are three separate packages so the package managers stay optional.
`node` ships only the runtime; add `npm` and/or `pnpm` next to it when you need them.

```nix
packages = [
  inputs.draftea-pkgs.packages.${system}.node
  inputs.draftea-pkgs.packages.${system}.npm   # optional
  inputs.draftea-pkgs.packages.${system}.pnpm  # optional
];
```

Keep `node` in the list: globally installed tools use `#!/usr/bin/env node`.

Global installs go outside the Nix store, so `npm install -g` and `pnpm add -g` work as usual:

| Tool   | Global location        | Binaries on `PATH`          | Override                                  |
| ------ | ---------------------- | --------------------------- | ----------------------------------------- |
| `npm`  | `$HOME/.npm-global`    | `$HOME/.npm-global/bin`     | `NPM_CONFIG_PREFIX`, `prefix=` in `~/.npmrc` or a project `.npmrc` |
| `pnpm` | `$HOME/.pnpm-global`   | `$HOME/.pnpm-global/bin`    | `PNPM_HOME`                               |

`nix develop` / `nix-shell` add those `bin` directories to `PATH` automatically. For other
consumers (devenv, home-manager, plain shells), add them yourself:

```bash
export PATH="$PATH:$HOME/.npm-global/bin:$HOME/.pnpm-global/bin"
```

The `npm` package is the copy bundled in the pinned Node release, so bump it together with `node`.

## Repository layout

```text
flake.nix             # flake-parts entrypoint; declares inputs and supported systems
nix/
  overlays/           # nixpkgs instantiation per system (allowUnfree, etc.)
  packages/           # one .nix file per derivation, wired via default.nix
  checks/             # smoke-test derivations, one per package
  shells/             # devShells (dev shell for working on this repo)
```

The flake exposes:

- `packages.<system>.<name>` for every derivation under `nix/packages`.
- `checks.<system>.<name>` — one smoke-test derivation per package; see
  [Tests](#tests) below.
- `devShells.<system>.default` — Nix linters, formatters, markdown/yaml/shell checkers, and the
  pre-commit framework.

## Tests

Each package has a corresponding smoke-test derivation under `nix/checks/`. Tests build only
when their assertions pass — a failed assertion fails the derivation.

```bash
# Run the whole suite (skips already-built tests, builds the rest)
nix flake check

# Run a single test
nix build .#checks.aarch64-darwin.go
nix build .#checks.aarch64-darwin.python

# Watch a test build with full logs
nix build .#checks.aarch64-darwin.pkl --print-build-logs
```

The tests cover, per package:

| Package      | Coverage                                                                            |
| ------------ | ----------------------------------------------------------------------------------- |
| `ejson`      | `keygen` produces a 32-byte Curve25519 keypair; full `encrypt`/`decrypt` round trip |
| `go`         | version matches pin; `GOROOT` resolves; `go build` compiles a stdlib-only program   |
| `go-migrate` | `migrate -version` matches pin; `migrate -help` advertises the usage banner         |
| `mockery`    | version matches pin; v3 command set present; `init` scaffolds config; generates a mock that compiles |
| `node`       | version matches pin; runs JavaScript; no bundled `npm`/`npx`/`corepack`; headers present |
| `npm`        | version matches pin; global prefix is `$HOME/.npm-global` and overridable; `npm install -g` lands there and runs; setup hook adds it to `PATH` |
| `pkl`        | `pkl --version` matches pin; `pkl eval` renders a minimal module                    |
| `pnpm`       | version matches pin; global bin dir is `$HOME/.pnpm-global/bin` and overridable; `pnpm add -g` lands there and runs; setup hook adds it to `PATH` |
| `python`     | version matches pin; `sys.version_info` correct; stdlib round trip; runs a script   |

When updating a derivation, also update the `expectedVersion` in the corresponding
`nix/checks/<name>.nix` so the version assertion stays in sync with the pin.

## Local development

Requires [Nix](https://nixos.org/download) with flakes enabled and (recommended)
[direnv](https://direnv.net/).

```bash
# With direnv — auto-enters the dev shell on cd into the repo
direnv allow

# Or manually
nix develop
```

Entering the dev shell installs `pre-commit` hooks (`pre-commit` and `commit-msg`) on first run.

### Common tasks

```bash
# Build a single derivation locally to validate it
nix build .#go
nix build .#pkl

# Run all configured pre-commit hooks
pre-commit run --all-files

# Format every Nix file
nixpkgs-fmt nix flake.nix
```

### Updating a derivation

1. Edit the `version` (and `release`, where present) in `nix/packages/<name>.nix`.
2. Refresh hashes for every platform listed under `sources` / `platforms`. Most derivations
   embed a comment with the exact prefetch command. As a generic recipe:

   ```bash
   nix-prefetch-url --type sha256 <url>
   # If the file requires a SRI hash, convert it:
   nix hash convert --hash-algo sha256 --to sri <base32>
   ```

3. Update the `expectedVersion` in `nix/checks/<name>.nix` to match.
   - `node`: hashes come from `https://nodejs.org/dist/v<version>/SHASUMS256.txt`. Also set
     `version` in `nix/packages/npm.nix` to the npm bundled in that release
     (`curl -s https://nodejs.org/dist/index.json`) and update the `npm` check.
   - `pnpm`: hashes come from the release asset digests
     (`gh api repos/pnpm/pnpm/releases/tags/v<version> --jq '.assets[] | .name + " " + .digest'`).
4. `nix build .#<name>` on at least one local platform, then `nix flake check` to run the suite.
5. Commit with a [Conventional Commits](https://www.conventionalcommits.org/) message — `deps`
   or `build` scope is appropriate for upstream bumps.

## CI workflows

Two workflows live under `.github/workflows/`:

### `pull_request.yml`

Runs on every pull request and validates the change end-to-end inside this repo's `dev` shell:

- **commit-check** — `cz check` against PR commits and the PR title.
- **lint** — `nixpkgs-fmt`, `statix`, `deadnix`, `shellcheck`, `shfmt`, `yamllint`,
  `markdownlint-cli2`, and `gitleaks`. Steps use `if: always()` so every linter still
  reports when an earlier one fails.
- **tests** — `nix flake check` builds every derivation under `nix/checks/`, exercising the
  smoke tests for all packages.

Nix is installed and the store cache is restored via Draftea's
[`configure-nix`](https://github.com/Drafteame/backend-ci/tree/main/.github/actions/configure-nix)
composite action; the `tests` job saves the cache after a successful run.

### `release.yml`

Runs on pushes to `main`. Uses backend-ci's `cz-bump` composite action with the re-exported
`ci-deploy` devshell (commitizen + git) to bump the version, write a changelog increment, and
push the tag back to `main`. Then [`softprops/action-gh-release`](https://github.com/softprops/action-gh-release)
publishes a GitHub release and a follow-up job moves the floating `v<major>` tag to the new
release.

### Required secrets

| Secret         | Used by                                            | Purpose                                                           |
| -------------- | -------------------------------------------------- | ----------------------------------------------------------------- |
| `ACCESS_TOKEN` | both workflows                                     | Fetches the private `backend-ci` flake input over HTTPS; release checkout |
| `GIT_NAME`     | release workflow                                   | `user.name` on the bump commit                                    |
| `GIT_EMAIL`    | release workflow                                   | `user.email` on the bump commit                                   |

`GITHUB_TOKEN` is provided by GitHub Actions automatically.

## Conventions

- Conventional Commits via [commitizen](https://commitizen-tools.github.io/commitizen/) — enforced
  by a `commit-msg` pre-commit hook.
- Nix formatting via [`nixpkgs-fmt`](https://github.com/nix-community/nixpkgs-fmt); linting via
  [`statix`](https://github.com/oppiliappan/statix) and [`deadnix`](https://github.com/astro/deadnix).
- Markdown lint via [`markdownlint-cli2`](https://github.com/DavidAnson/markdownlint-cli2).
- YAML lint via [`yamllint`](https://github.com/adrienverge/yamllint).
- Shell scripts via [`shellcheck`](https://www.shellcheck.net/) and
  [`shfmt`](https://github.com/mvdan/sh).
- Secret scanning via [`gitleaks`](https://github.com/gitleaks/gitleaks).
