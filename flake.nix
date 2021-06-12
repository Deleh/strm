{
  description = "Stream media files over SSH";

  nixConfig.bash-prompt = "\[strm-develop\]$ ";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Use mpv with scripts
          mpv = (pkgs.mpv-with-scripts.override {
            scripts = [
              pkgs.mpvScripts.mpris
            ];
          });
        in
        {

          # Package
          packages.strm =
            pkgs.stdenv.mkDerivation {
              name = "strm";
              src = self;
              propagatedBuildInputs = [
                mpv
              ];
              installPhase = ''
                install -m 755 -D strm $out/bin/strm
              '';
            };
          defaultPackage = self.packages.${system}.strm;

          # Development shell
          devShell = pkgs.mkShell {
            buildInputs = [
              mpv
            ];
          };

        }

      );
}
