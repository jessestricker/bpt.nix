{
  description = "A C++ Build System and Library Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }: let
    bptVersion = "1.0.0-beta.1";
    bptBinaries = {
      "x86_64-linux" = {
        fileName = "bpt-linux-x64";
        sha256 = "d30d66396b1a552ca0fcbf0f31bb12edb5edae7911eb23f34addf4bcbec19904";
      };
      "x86_64-darwin" = {
        fileName = "bpt-macos-x64";
        sha256 = "2fd3b7ade3e7146e759f88e9c3504e2afd7d387b7dd604de71f2384aca456f92";
      };
    };
    supportedSystems = builtins.attrNames bptBinaries;
  in
    utils.lib.eachSystem supportedSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      bptBinary = bptBinaries.${system};
    in rec {
      packages.bpt = pkgs.stdenv.mkDerivation {
        pname = "bpt";
        version = bptVersion;

        src = pkgs.fetchurl {
          url = "https://github.com/vector-of-bool/bpt/releases/download/${bptVersion}/${bptBinary.fileName}";
          sha256 = bptBinary.sha256;
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
