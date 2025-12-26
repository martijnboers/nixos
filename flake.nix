{
  description = "Everything, everywhere, all at once";

  inputs = {
    self.submodules = true; # git submodules
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-citrix.url = "github:NixOS/nixpkgs/nixos-25.05";
    hardware.url = "github:NixOS/nixos-hardware";
    hardware-fork.url = "github:martijnboers/nixos-hardware";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    # https://github.com/DeterminateSystems/nix-src/releases
    determinate.url = "github:DeterminateSystems/nix-src/v3.14.0";

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
      nixos-raspberrypi,
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

      importSystem =
        name:
        {
          system,
          modules ? [ ],
          call ? lib.nixosSystem,
        }:
        let
          systemconfig = ./hosts/${name}/default.nix;
          hardwareconfig = ./hosts/${name}/hardware.nix;
          homeconfig = ./hosts/${name}/home.nix;
        in
        call {
          inherit system;
          specialArgs = { inherit inputs nixos-raspberrypi; };
          modules =
            with inputs;
            [
              systemconfig
              hardwareconfig
              ./nixos/system.nix

              {
                nixpkgs = {
                  config.allowUnfree = true;
                  overlays = [
                    outputs.overlays.additions
                    outputs.overlays.modifications
                    outputs.overlays.alternative-pkgs
                  ];
                };
              }

              agenix.nixosModules.default # secrets
              home-manager.nixosModules.home-manager
              lanzaboote.nixosModules.lanzaboote # secureboot
              nix-mineral.nixosModules.nix-mineral # schizo settings
              secrets.outPath # so config.hidden becomes available

              {
                home-manager.useGlobalPkgs = true;
                home-manager.users.martijn = import homeconfig;
                home-manager.extraSpecialArgs = { inherit inputs system; };
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
      nixosConfigurations.shoryuken = importSystem "shoryuken" {
        system = "x86_64-linux";
        modules = [ inputs.disko.nixosModules.disko ];
      };
      nixosConfigurations.rekkaken = importSystem "rekkaken" {
        system = "x86_64-linux";
        modules = [ inputs.disko.nixosModules.disko ];
      };

      # ------------ Servers ------------
      nixosConfigurations.tenshin = importSystem "tenshin" {
        system = "aarch64-linux";
        modules = [ inputs.hardware.nixosModules.raspberry-pi-4 ];
      };
      nixosConfigurations.suzaku = importSystem "suzaku" {
        system = "aarch64-linux";
        call = inputs.nixos-raspberrypi.lib.nixosSystem;
        modules = with inputs.nixos-raspberrypi.nixosModules; [
          inputs.disko.nixosModules.disko
          raspberry-pi-5.page-size-16k
          raspberry-pi-5.base
        ];
      };
      nixosConfigurations.hadouken = importSystem "hadouken" {
        system = "x86_64-linux";
      };
      nixosConfigurations.dosukoi = importSystem "dosukoi" {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
        ];
      };
      nixosConfigurations.tatsumaki = importSystem "tatsumaki" {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          inputs.nix-bitcoin.nixosModules.default
        ];
      };

      # -------------- PCs --------------
      nixosConfigurations.nurma = importSystem "nurma" {
        system = "x86_64-linux";
      };
      nixosConfigurations.paddy = importSystem "paddy" {
        system = "x86_64-linux";
        modules = [ inputs.hardware-fork.nixosModules.dell-da14250 ];
      };
      nixosConfigurations.donk = importSystem "donk" {
        system = "x86_64-linux";
        modules = [ inputs.hardware.nixosModules.framework-12-13th-gen-intel ];
      };
    };
}
