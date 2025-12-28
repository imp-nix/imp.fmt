/**
  Core library functions for formatter configuration.

  Internal module used by `make` and `makeEval` to construct treefmt
  configurations from user-provided parameters.
*/
{ pkgs, lib }:
let
  mdformatLib = import ./formatters/mdformat.nix { inherit pkgs lib; };
  rustLib = import ./formatters/rust.nix { inherit pkgs lib; };
  kdlfmtLib = import ./formatters/kdlfmt.nix { inherit pkgs lib; };
in
{
  /**
    Build the treefmt configuration attrset.

    This is the shared logic used by both `make` and `makeEval` functions.
    Constructs the final treefmt configuration by combining formatter-specific
    settings based on enabled features.

    # Arguments

    excludes
    : Glob patterns to exclude from formatting.

    extraFormatters
    : Additional treefmt formatter settings.

    nixfmt
    : Attrset with `enable` boolean for nixfmt.

    mdformat
    : Attrset with `enable` boolean for mdformat.

    rust
    : Attrset with `enable` boolean for Rust formatting.

    projectRootFile
    : File that marks the project root.
  */
  buildTreefmtConfig =
    {
      excludes,
      extraFormatters,
      nixfmt,
      mdformat,
      rust,
      kdlfmt,
      projectRootFile,
    }:
    let
      mdformatPkg = mdformatLib.package;
      cargoSortWrapper = rustLib.cargo-sort-wrapper;
      kdlfmtWrapper = kdlfmtLib.wrapper;

      mdformatSettings = if mdformat.enable then mdformatLib.settings mdformatPkg else { };
      rustSettings = if rust.enable then rustLib.settings cargoSortWrapper else { };
      kdlfmtSettings = if kdlfmt.enable then kdlfmtLib.settings kdlfmtWrapper else { };
    in
    {
      inherit projectRootFile;
      programs.nixfmt.enable = nixfmt.enable;
      /**
        rustfmt configuration.

        Allows overriding the package and edition to match project-specific
        toolchains (e.g. nightly) and ensure rustfmt.toml rules are respected.
      */
      programs.rustfmt = {
        enable = rust.enable;
        package = if rust.package != null then rust.package else pkgs.rustfmt;
      } // (lib.optionalAttrs (rust.edition != null) {
        edition = rust.edition;
      });
      settings.global.excludes = excludes;
      settings.formatter = mdformatSettings // rustSettings // kdlfmtSettings // extraFormatters;
    };
}
