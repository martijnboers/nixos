{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    # with working qt6, move back to github:danth/stylix
    stylix.url = "github:Jackaed/stylix/f77828f724cbf7c140acae6dc53472f1570a0712";

    # Macbook stuff
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
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
                home-manager.useGlobalPkgs = true;
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
    };

    nixosConfigurations.shoryuken = mkSystem "shoryuken" {
      system = "x86_64-linux";
      extraModules = [inputs.disko.nixosModules.disko];
    };

    nixosConfigurations.tenshin = mkSystem "tenshin" {
      system = "aarch64-linux";
    };

    darwinConfigurations.lapdance = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs outputs;};
      modules = [
        ./hosts/lapdance/system.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs outputs;};
          home-manager.users.martijn = import ./hosts/lapdance/home.nix;
        }
      ];
    };
  };
}
