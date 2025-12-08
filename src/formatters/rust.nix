/**
  Rust formatting configuration (rustfmt + cargo-sort).

  Provides cargo-sort wrapper for treefmt integration. The rustfmt
  configuration is handled directly by treefmt-nix's built-in support.
*/
{ pkgs, lib }:
{
  /**
    cargo-sort wrapper that handles treefmt's file-based invocation.

    treefmt passes individual file paths, but cargo-sort operates on
    directories. This wrapper extracts the directory from each file path
    and runs cargo-sort on it.

    # Implementation

    Separates options (starting with `--`) from file paths, then for each
    file, runs cargo-sort on its parent directory.
  */
  cargo-sort-wrapper = pkgs.writeShellScriptBin "cargo-sort-wrapper" ''
    set -euo pipefail
    opts=()
    files=()
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --*) opts+=("$1"); shift ;;
        *) files+=("$1"); shift ;;
      esac
    done
    for file in "''${files[@]}"; do
      ${lib.getExe pkgs.cargo-sort} "''${opts[@]}" "$(dirname "$file")"
    done
  '';

  /**
    Generate treefmt settings for cargo-sort.

    # Arguments

    cargo-sort-wrapper
    : The wrapper script derivation.

    # Returns

    Attrset with treefmt formatter configuration for cargo-sort.
    Matches all Cargo.toml files in the project.
  */
  settings = cargo-sort-wrapper: {
    cargo-sort = {
      command = "${cargo-sort-wrapper}/bin/cargo-sort-wrapper";
      options = [ "--workspace" ];
      includes = [
        "Cargo.toml"
        "**/Cargo.toml"
      ];
    };
  };
}
