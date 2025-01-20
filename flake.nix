{
  description = "Nix flake for building coqfmt from GitHub";
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "opam-nix/nixpkgs";
    coqfmt = {
      url = "github:toku-sa-n/coqfmt";
      flake = false;
    };
  };
  outputs = { self, flake-utils, opam-nix, nixpkgs, coqfmt }@inputs:
    let package = "coqfmt";
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        scope =
          on.buildDuneProject {  } package coqfmt { ocaml-system = "*"; coq = "*"; };
        overlay = final: prev:
          {
          };
      in {
        legacyPackages = scope.overrideScope overlay;

        packages.default = self.legacyPackages.${system}.${package};
      });
}
