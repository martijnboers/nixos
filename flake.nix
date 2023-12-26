{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
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

    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # For Raspberry Pi
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    mkSystem = import ./lib/mksystem.nix {
      inherit nixpkgs inputs home-manager;
    };
  in {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    overlays = import ./overlays {inherit inputs;};

    nixosConfigurations.glassdoor = mkSystem "glassdoor" {
      system = "x86_64-linux";
      special-options = {
        isWork = true;
        isDesktop = true;
        isPersonal = true;
      };
      extra-modules = [
        ./nixos/desktop.nix
      ];
    };

    nixosConfigurations.teak = mkSystem "teak" {
      system = "aarch64-linux";
      special-options = {
        isWork = false;
        isDesktop = false;
        isPersonal = false;
      };
      extra-modules = [
        nixos-hardware.nixosModules.raspberry-pi-4
      ];
    };

    nixosConfigurations.rihanna = mkSystem "rihanna" {
      system = "x86_64-linux";
      special-options = {
        isWork = true;
        isDesktop = true;
        isPersonal = false;
      };
      extra-modules = [
        ./nixos/desktop.nix
      ];
    };
  };
}
