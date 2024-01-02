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
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
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
    mkSystem = import ./lib/mksystem.nix {
      inherit nixpkgs inputs outputs home-manager sops-nix;
    };
  in {
    # Custom packages, accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

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

    nixosConfigurations.testbed = mkSystem "testbed" {
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
