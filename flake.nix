{
  description = "R Data Science Project";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:

      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;  # For Positron
        };

        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

      # Define shell (system-level) tools for the project environment here:
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            positron-bin
            quarto
            
            # for LaTeX
            tectonic
            texlive.combined.scheme-medium
          ] ++

          (with pkgs-unstable; [
            R
          ]) ++ 

          (with pkgs.rPackages; [
            devtools
            gt
            gtsummary
            quarto
            tibble
            tidyverse
            tidymodels
          ]);

          
          # Confirmation message:
          shellHook = ''
            echo "📊 $(basename $PWD) R & Quarto Environment Ready"
          '';
        };
      });
}
