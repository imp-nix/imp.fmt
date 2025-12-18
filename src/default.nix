/**
  Reusable formatter configuration for Nix flakes.

  Provides opinionated treefmt-nix configurations with minimal dependencies.
  Supports Nix, Markdown, and optionally Rust formatting.

  # Example

  ```nix
  {
    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      treefmt-nix.url = "github:numtide/treefmt-nix";
      imp-fmt.url = "github:imp-nix/imp.fmt";
    };

    outputs = { nixpkgs, treefmt-nix, imp-fmt, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      formatter = forAllSystems (system:
        imp-fmt.lib.make {
          pkgs = nixpkgs.legacyPackages.${system};
          inherit treefmt-nix;
        }
      );
    };
  }
  ```

  With custom options:

  ```nix
  imp-fmt.lib.make {
    pkgs = nixpkgs.legacyPackages.${system};
    inherit treefmt-nix;
    excludes = [ "vendor/*" "*.gen.nix" ];
    rust.enable = true;  # enables rustfmt + cargo-sort
    mdformat.enable = false;
  }
  ```
*/
let
  /**
    Default parameter values extracted to avoid duplication.
  */
  defaultParams = {
    excludes = [ ];
    extraFormatters = { };
    nixfmt = {
      enable = true;
    };
    mdformat = {
      enable = true;
    };
    rust = {
      enable = false;
      package = null;
      edition = null;
    };
    projectRootFile = "flake.nix";
  };

  /**
    Extract formatter params (filtering out pkgs and treefmt-nix).
  */
  extractParams =
    {
      excludes ? defaultParams.excludes,
      extraFormatters ? defaultParams.extraFormatters,
      nixfmt ? defaultParams.nixfmt,
      mdformat ? defaultParams.mdformat,
      rust ? defaultParams.rust,
      projectRootFile ? defaultParams.projectRootFile,
      ...
    }:
    {
      inherit
        excludes
        extraFormatters
        projectRootFile
        ;
      nixfmt = defaultParams.nixfmt // nixfmt;
      mdformat = defaultParams.mdformat // mdformat;
      rust = defaultParams.rust // rust;
    };
in
{
  /**
    Create a formatter derivation for use in flake outputs.

    Returns a treefmt wrapper suitable for `formatter.<system>`.

    # Arguments

    pkgs
    : Nixpkgs instance.

    treefmt-nix
    : treefmt-nix flake input.

    excludes
    : (optional) List of glob patterns to exclude from formatting. Default: `[]`.

    extraFormatters
    : (optional) Additional treefmt formatter settings (merged with defaults). Default: `{}`.

    nixfmt
    : (optional) Attrset with `enable` boolean for nixfmt. Default: `{ enable = true; }`.

    mdformat
    : (optional) Attrset with `enable` boolean for mdformat (with GFM, frontmatter, footnote plugins). Default: `{ enable = true; }`.

    rust
    : (optional) Attrset with Rust formatting options:
      - `enable`: (boolean) Enable rustfmt + cargo-sort. Default: `false`.
      - `package`: (package) Custom rustfmt package to use. Default: `pkgs.rustfmt`.
      - `edition`: (string) Rust edition to use. Default: `null`.

    projectRootFile
    : (optional) File that marks the project root for treefmt. Default: `"flake.nix"`.

    # Example

    ```nix
    formatter = imp-fmt.lib.make {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      inherit treefmt-nix;
      excludes = [ "generated/*" ];
      rust.enable = true;
    };
    ```
  */
  make =
    args@{
      pkgs,
      treefmt-nix,
      excludes ? defaultParams.excludes,
      extraFormatters ? defaultParams.extraFormatters,
      nixfmt ? defaultParams.nixfmt,
      mdformat ? defaultParams.mdformat,
      rust ? defaultParams.rust,
      projectRootFile ? defaultParams.projectRootFile,
    }:
    let
      lib = pkgs.lib;
      libFuncs = import ./lib.nix { inherit pkgs lib; };
      params = extractParams args;
      treefmtConfig = libFuncs.buildTreefmtConfig params;
      treefmtEval = treefmt-nix.lib.evalModule pkgs treefmtConfig;
    in
    treefmtEval.config.build.wrapper;

  /**
    Create a treefmt evaluation config.

    Returns the full treefmt evaluation for advanced use cases where
    you need access to `config.build.check` or other treefmt internals.

    # Arguments

    Same as `make` function.

    # Example

    ```nix
    # Use in flake checks
    checks.formatting =
      let
        formatterEval = imp-fmt.lib.makeEval {
          inherit pkgs treefmt-nix;
        };
      in
      formatterEval.config.build.check self;
    ```
  */
  makeEval =
    args@{
      pkgs,
      treefmt-nix,
      excludes ? defaultParams.excludes,
      extraFormatters ? defaultParams.extraFormatters,
      nixfmt ? defaultParams.nixfmt,
      mdformat ? defaultParams.mdformat,
      rust ? defaultParams.rust,
      projectRootFile ? defaultParams.projectRootFile,
    }:
    let
      lib = pkgs.lib;
      libFuncs = import ./lib.nix { inherit pkgs lib; };
      params = extractParams args;
      treefmtConfig = libFuncs.buildTreefmtConfig params;
    in
    treefmt-nix.lib.evalModule pkgs treefmtConfig;
}
