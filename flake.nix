{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager kde
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    agenix.url = "github:ryantm/agenix";

    # On the fly running of programs
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disk setup for nixos-anywhere
    disko.url = "github:nix-community/disko";

    # rice
    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkSystem = name: {
      system,
      extraModules ? [],
    }: let
      systemconfig = ./hosts/${name}/default.nix;
      hardwareconfig = ./hosts/${name}/hardware.nix;
      homeconfig = ./hosts/${name}/home.nix;
    in
      with nixpkgs.lib;
        nixosSystem {
          specialArgs = {inherit inputs outputs;};
          extraModules = extraModules;
          modules =
            [
              systemconfig
              hardwareconfig

              # Base NixOS configuration
              ./nixos/system.nix

              # Secret management
              inputs.agenix.nixosModules.default
              {
                environment.systemPackages = [inputs.agenix.packages.${system}.default];
              }

              home-manager.nixosModules.home-manager
              {
                home-manager.useUserPackages = true;
                home-manager.users.martijn = import homeconfig;
                home-manager.extraSpecialArgs = {inherit inputs outputs system;};
              }
            ]
            ++ extraModules;
        };
  in {
    # Custom packages, accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    overlays = import ./overlays {inherit inputs;};

    nixosConfigurations.glassdoor = mkSystem "glassdoor" {
      system = "x86_64-linux";
    };

    nixosConfigurations.hadouken = mkSystem "hadouken" {
      system = "x86_64-linux";
      extraModules = [];
    };

    nixosConfigurations.lapdance = mkSystem "lapdance" {
      system = "x86_64-linux";
    };

    nixosConfigurations.shoryuken = mkSystem "shoryuken" {
      system = "x86_64-linux";
      extraModules = [inputs.disko.nixosModules.disko];
    };

    nixosConfigurations.testbed = mkSystem "testbed" {
      system = "x86_64-linux";
    };
  };
}
