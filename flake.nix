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
  } @ inputs: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    overlays = import ./overlays {inherit inputs;};

    nixosConfigurations.glassdoor = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # Makes all modules receive inputs of flake
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/glassdoor/default.nix
        ./hosts/glassdoor/hardware.nix
        # Enable KDE
        ./nixos/desktop.nix
        # Base NixOS configuration
        ./nixos/system.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.martijn = import ./home/config.nix;
          home-manager.extraSpecialArgs = {inherit inputs;};
        }
      ];
    };

    nixosConfigurations.teak = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      # Makes all modules receive inputs of flake
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/hosts/teak/default.nix
        # TODO: hardware
        # Base NixOS configuration
        ./nixos/system.nix

        nixos-hardware.nixosModules.raspberry-pi-4
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.martijn = import ./home/config.nix;
          home-manager.extraSpecialArgs = {inherit inputs;};
        }
      ];
    };
  };
}
