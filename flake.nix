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
    agenix.url = "github:ryantm/agenix";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    agenix,
    nix-index-database,
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
    mkSystem = name: {
      system,
      hostenv,
    }: let
      # The config files for this system.
      systemconfig = ./hosts/${name}/default.nix;
      hardwareconfig = ./hosts/${name}/hardware.nix;
    in
      with nixpkgs.lib;
        nixosSystem {
          modules =
            [
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
                home-manager.users.martijn = import ./home/default.nix;
                home-manager.extraSpecialArgs = {inherit inputs outputs hostenv;};
              }
            ]
            ++ optionals hostenv.desktop [./nixos/desktop.nix];
        };
  in {
    # Custom packages, accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    overlays = import ./overlays {inherit inputs;};

    nixosConfigurations.glassdoor = mkSystem "glassdoor" {
      system = "x86_64-linux";
      hostenv = {
        work = true;
        desktop = true;
        personal = true;
      };
    };

    nixosConfigurations.teak = mkSystem "teak" {
      system = "aarch64-linux";
      hostenv = {
        work = false;
        desktop = false;
        personal = false;
      };
    };

    nixosConfigurations.rihanna = mkSystem "rihanna" {
      system = "x86_64-linux";
      hostenv = {
        work = true;
        desktop = true;
        personal = false;
      };
    };

    nixosConfigurations.testbed = mkSystem "testbed" {
      system = "x86_64-linux";
      hostenv = {
        work = true;
        desktop = true;
        personal = false;
      };
    };
  };
}
