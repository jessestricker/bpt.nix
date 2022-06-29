{
  description = "A generic flake.nix template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      version = "1.0.0-beta.1";
    in rec {
      packages.bpt = pkgs.stdenv.mkDerivation {
        pname = "bpt";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://github.com/vector-of-bool/bpt/releases/download/${version}/bpt-linux-x64";
          sha256 = "d30d66396b1a552ca0fcbf0f31bb12edb5edae7911eb23f34addf4bcbec19904";
        };

        phases = ["installPhase"];
        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin
          cp $src $out/bin/bpt
          chmod +x $out/bin/bpt

          runHook postInstall
        '';
      };
      packages.default = packages.bpt;

      apps.bpt = utils.lib.mkApp {
        drv = packages.bpt;
      };
      apps.default = apps.bpt;

      formatter = pkgs.alejandra;
    });
}
