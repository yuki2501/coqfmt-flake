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
          on.buildDuneProject {  } package coqfmt { ocaml-system = "*";  };
        overlay = final: prev:
          {
            coqfmt = prev.coqfmt.overrideAttrs(old: {
              opam__coq____installed = "true";
              doNixSupport = false;
              propagateInputs = false;
              exportSetupHook = false;
              removeOcamlReferences = true;
            });
          };
      in {
        legacyPackages = scope.overrideScope overlay;

        packages.default = self.legacyPackages.${system}.${package};
      });
}
