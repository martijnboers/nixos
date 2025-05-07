{
  description = "Everything, everywhere, all at once";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.11";
    nixpkgs-fork.url = "github:martijnboers/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/martijnboers/secrets.git?ref=master";
      flake = false;
    };

    # On the fly running of programs
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Disk setup for nixos-anywhere
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # All-in-one bitcoin node
    nix-bitcoin.url = "github:martijnboers/nix-bitcoin/master";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs"; # Can be pinned to nixpkgs-23.11-darwin
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkSystem =
        name:
        {
          system,
          extraModules ? [ ],
        }:
        let
          systemconfig = ./hosts/${name}/default.nix;
          hardwareconfig = ./hosts/${name}/hardware.nix;
          homeconfig = ./hosts/${name}/home.nix;
        in
        with nixpkgs.lib;
        nixosSystem {
          inherit system;
          inherit extraModules;

          specialArgs = { inherit inputs outputs; };
          modules = [
            systemconfig
            hardwareconfig

            # Base NixOS configuration
            ./nixos/system.nix

            # Secret management
            inputs.agenix.nixosModules.default
            {
              environment.systemPackages = [ inputs.agenix.packages.${system}.default ];
            }
            inputs.secrets.outPath

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.martijn = import homeconfig;
              home-manager.extraSpecialArgs = { inherit inputs outputs system; };
            }
          ] ++ extraModules;
        };
    in
    {
      # Custom packages, accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      # Custom adjustments to packages
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations.nurma = mkSystem "nurma" {
        system = "x86_64-linux";
      };

      nixosConfigurations.hadouken = mkSystem "hadouken" {
        system = "x86_64-linux";
      };

      nixosConfigurations.shoryuken = mkSystem "shoryuken" {
        system = "x86_64-linux";
        extraModules = [ inputs.disko.nixosModules.disko ];
      };

      nixosConfigurations.tatsumaki = mkSystem "tatsumaki" {
        system = "x86_64-linux";
        extraModules = [
          inputs.disko.nixosModules.disko
          inputs.nix-bitcoin.nixosModules.default
        ];
      };

      nixosConfigurations.tenshin = mkSystem "tenshin" {
        system = "aarch64-linux";
      };

      darwinConfigurations.paddy = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/paddy/system.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs outputs; };
            home-manager.users.martijn = import ./hosts/paddy/home.nix;
          }
        ];
      };
    };
}
