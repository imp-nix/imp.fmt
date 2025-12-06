# imp.fmt

Reusable formatter configuration for Nix flakes. Provides consistent formatting
across the imp ecosystem with minimal dependencies.

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    imp-fmt.url = "github:imp-nix/imp.fmt";
    imp-fmt.inputs.nixpkgs.follows = "nixpkgs";
    imp-fmt.inputs.treefmt-nix.follows = "treefmt-nix";
  };

  outputs = { nixpkgs, treefmt-nix, imp-fmt, ... }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
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

## Configuration

The `make` and `makeEval` functions accept these options:

| Option            | Default       | Description                                                 |
| ----------------- | ------------- | ----------------------------------------------------------- |
| `pkgs`            | required      | Nixpkgs instance                                            |
| `treefmt-nix`     | required      | treefmt-nix input                                           |
| `excludes`        | `[]`          | Paths to exclude from formatting                            |
| `extraFormatters` | `{}`          | Additional treefmt formatter settings                       |
| `nixfmt.enable`   | `true`        | Format Nix files with nixfmt                                |
| `mdformat.enable` | `true`        | Format Markdown with mdformat (GFM, frontmatter, footnotes) |
| `rust.enable`     | `false`       | Format Rust with rustfmt + cargo-sort                       |
| `projectRootFile` | `"flake.nix"` | File that marks project root                                |

## Functions

- `lib.make` - Returns a formatter derivation for `formatter.<system>`
- `lib.makeEval` - Returns the full treefmt evaluation for access to `config.build.check`

## License

MIT
