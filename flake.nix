{
  description = "Reusable formatter configuration for Nix flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      formatterLib = import ./src;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      lib = formatterLib;

      formatter = forAllSystems (
        system:
        formatterLib.make {
          pkgs = nixpkgs.legacyPackages.${system};
          inherit treefmt-nix;
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          formatterEval = formatterLib.makeEval {
            inherit pkgs treefmt-nix;
          };
        in
        {
          formatting = formatterEval.config.build.check self;
        }
      );
    };
}
