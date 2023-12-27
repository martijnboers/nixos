{
  nixpkgs,
  inputs,
  home-manager,
  ...
}: name: {
  system,
  extra-modules,
  special-options,
}: let
  # The config files for this system.
  systemconfig = ../hosts/${name}/default.nix;
  hardwareconfig = ../hosts/${name}/hardware.nix;
in
  nixpkgs.lib.nixosSystem {
    inherit system;

    modules =
      [
        systemconfig
        hardwareconfig

        # Base NixOS configuration
        ../nixos/system.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.martijn = import ../home/default.nix;
          home-manager.extraSpecialArgs = {inherit inputs special-options;};
        }
      ]
      ++ extra-modules;
  }
