{
  description = "Everything, everywhere, all at once";

  inputs = {
    self.submodules = true; # git submodules
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    hardware.url = "github:NixOS/nixos-hardware";
    hardware-fork.url = "github:martijnboers/nixos-hardware";

    # https://github.com/DeterminateSystems/nix-src/releases
    determinate.url = "github:DeterminateSystems/nix-src/v3.12.0";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-bitcoin = {
      url = "github:fort-nix/nix-bitcoin/master";
    };

    nix-mineral = {
      url = "github:martijnboers/nix-mineral?ref=seikm-refactor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elephant.url = "github:abenz1267/elephant/v2.16.1";
    walker = {
      url = "github:abenz1267/walker/v2.11.2";
      inputs.elephant.follows = "elephant";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "./secrets";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;

      mkSystem =
        name:
        {
          system,
          modules ? [ ],
        }:
        let
          systemconfig = ./hosts/${name}/default.nix;
          hardwareconfig = ./hosts/${name}/hardware.nix;
          homeconfig = ./hosts/${name}/home.nix;
        in
        lib.nixosSystem {
          inherit system;

          specialArgs = { inherit inputs outputs; };
          modules =
            with inputs;
            [
              systemconfig
              hardwareconfig
              ./nixos/system.nix

              home-manager.nixosModules.home-manager
              lanzaboote.nixosModules.lanzaboote # secureboot
              nix-mineral.nixosModules.nix-mineral # schizo settings
              agenix.nixosModules.default # secrets
              secrets.outPath # so config.hidden becomes available

              {
                home-manager.useGlobalPkgs = true;
                home-manager.users.martijn = import homeconfig;
                home-manager.extraSpecialArgs = { inherit inputs outputs system; };
              }
            ]
            ++ modules;
        };
    in
    {
      overlays = import ./overlays { inherit inputs; };
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      # ------------ Cloud ------------
      nixosConfigurations.shoryuken = mkSystem "shoryuken" {
        system = "x86_64-linux";
        modules = [ inputs.disko.nixosModules.disko ];
      };
      nixosConfigurations.rekkaken = mkSystem "rekkaken" {
        system = "x86_64-linux";
        modules = [ inputs.disko.nixosModules.disko ];
      };

      # ------------ Servers ------------
      nixosConfigurations.tenshin = mkSystem "tenshin" {
        system = "aarch64-linux";
        modules = [ inputs.hardware.nixosModules.raspberry-pi-4 ];
      };
      nixosConfigurations.hadouken = mkSystem "hadouken" {
        system = "x86_64-linux";
      };
      nixosConfigurations.dosukoi = mkSystem "dosukoi" {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
        ];
      };
      nixosConfigurations.tatsumaki = mkSystem "tatsumaki" {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          inputs.nix-bitcoin.nixosModules.default
        ];
      };

      # -------------- PCs --------------
      nixosConfigurations.nurma = mkSystem "nurma" {
        system = "x86_64-linux";
      };
      nixosConfigurations.paddy = mkSystem "paddy" {
        system = "x86_64-linux";
        modules = [ inputs.hardware-fork.nixosModules.dell-da14250 ];
      };
      nixosConfigurations.donk = mkSystem "donk" {
        system = "x86_64-linux";
        modules = [ inputs.hardware.nixosModules.framework-12-13th-gen-intel ];
      };
    };
}
