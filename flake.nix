{
  description = "Everything, everywhere, all at once";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    self.submodules = true; # add secrets
    iio-hyprland.url = "github:JeanSchoeller/iio-hyprland";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nh = {
      url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "./secrets";
      flake = false;
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-bitcoin = {
      url = "github:fort-nix/nix-bitcoin/master";
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
              agenix.nixosModules.default
              determinate.nixosModules.default
              lanzaboote.nixosModules.lanzaboote
              secrets.outPath # so secrets/defaults becomes available

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
      # Custom packages, accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      # Custom adjustments to packages
      overlays = import ./overlays { inherit inputs; };

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
        modules = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];
      };
      nixosConfigurations.hadouken = mkSystem "hadouken" {
        system = "x86_64-linux";
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
      nixosConfigurations.donk = mkSystem "donk" {
        system = "x86_64-linux";
        modules = [ inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel ];
      };
    };
}
