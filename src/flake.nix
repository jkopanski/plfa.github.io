{
  description = "Programming Language Foundations in Agda";

  inputs = {
    overture.url = "sourcehut:~madnat/overture";
    nixpkgs.follows = "overture/nixpkgs";
    utils.follows = "overture/utils";
  };

  outputs = inputs@{ self, nixpkgs, utils, ... }:
    (utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.overture.overlays.default ];
        };
        agdaWithLibraries = pkgs.agda.withPackages (p: [
          p.standard-library
        ]);

      in {
        checks.whitespace = pkgs.stdenvNoCC.mkDerivation {
          name = "check-whitespace";
          dontBuild = true;
          src = ./.;
          doCheck = true;
          checkPhase = ''
            ${pkgs.haskellPackages.fix-whitespace.bin}/bin/fix-whitespace --check
          '';
          installPhase = ''mkdir "$out"'';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            agdaWithLibraries
            pkgs.haskellPackages.fix-whitespace
          ];
        };

        packages.default = pkgs.agdaPackages.mkDerivation {
          pname = "plfa";
          version = "22.08";
          src = ./.;

          buildInputs = with pkgs.agdaPackages; [
            standard-library
          ];

          meta = {
            description = "Programming Language Foundations in Agda";
            homepage = "https://plfa.github.io/";
          };
        };
      }
    ));
}
