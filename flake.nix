{
  description = "Stream media files over SSH";

  nixConfig.bash-prompt = "\[\\e[1mstrm-dev\\e[0m:\\w\]$ ";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

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
              patchPhase = with pkgs; ''
                substituteInPlace strm \
                  --replace mpv\  ${mpv}/bin/mpv\
              '';
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
