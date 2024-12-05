{
  description = "Nix flake for building coqfmt from GitHub";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, opam-nix, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; };
    opam = opam-nix.lib.${system};

    # Fetch coqfmt from GitHub
    coqfmtSrc = pkgs.fetchFromGitHub {
      owner = "toku-sa-n";
      repo = "coqfmt";
      rev = "main"; 
      sha256 = "HYIzFZ5PCJzWKpcK9ilnw8x7vKGeg3Q+F70kcQXkDs8=";  
    };

    repos = [
      (opam.makeOpamRepoRec coqfmtSrc) 
      opam.opamRepository              
    ];

    query = {
      coqfmt = "*";            
      coq = "8.20.0";          
      dune = "*";              
      ocaml-system = "*";      
    };

    scope = opam.queryToScope {
      inherit repos;
      resolveArgs = {
        with-test = true;  
        with-doc = true;  
      };
    } query;

    patchedScope = scope.overrideScope (self: super: {
      "conf-pkg-config" = super."conf-pkg-config".overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [ pkgs.pkg-config ];
      });
    });

    coqfmtWithPkgConfig = patchedScope.coqfmt;

  in {
    defaultPackage = coqfmtWithPkgConfig;
    packages.default = coqfmtWithPkgConfig;
  });
}

