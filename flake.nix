{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager kde
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    agenix.url = "github:ryantm/agenix";

    # Run unpatched bins
    nix-alien.url = "github:thiagokokada/nix-alien";

    # On the fly running of programs
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declare vms declarative
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    agenix,
    nix-index-database,
    nix-alien,
    microvm,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Abstract generating system code here
    mkSystem = name: {system}: let
      # The config files for this system.
      systemconfig = ./hosts/${name}/default.nix;
      hardwareconfig = ./hosts/${name}/hardware.nix;
      homeconfig = ./hosts/${name}/home.nix;
    in
      with nixpkgs.lib;
        nixosSystem {
          specialArgs = {inherit inputs outputs;};
          modules = [
            systemconfig
            hardwareconfig

            # Base NixOS configuration
            ./nixos/system.nix

            # Secret management
            agenix.nixosModules.default
            {
              environment.systemPackages = [agenix.packages.${system}.default];
            }

            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.martijn = import homeconfig;
              home-manager.extraSpecialArgs = {inherit inputs outputs system;};
            }
            # Declarative vm config
            microvm.nixosModules.host
          ];
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
    };

    nixosConfigurations.lapdance = mkSystem "lapdance" {
      system = "x86_64-linux";
    };

    nixosConfigurations.testbed = mkSystem "testbed" {
      system = "x86_64-linux";
    };

    nixosConfigurations.shoryuken = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        microvm.nixosModules.microvm
        ./hosts/shoryuken
      ];
    };
  };
}
