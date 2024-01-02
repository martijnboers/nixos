{
  nixpkgs,
  inputs,
  outputs,
  home-manager,
  agenix,
  ...
}: name: {
  system,
  extra-modules,
  special-options,
}: let
  # The config files for this system.
  systemconfig = ../hosts/${name}/default.nix;
  hardwareconfig = ../hosts/${name}/hardware.nix;
  sopsconfig = ../secrets/${name}.yaml;
in
  nixpkgs.lib.nixosSystem {
    modules =
      [
        systemconfig
        hardwareconfig

        # Base NixOS configuration
        ../nixos/system.nix

        # Secret management
        agenix.nixosModules.default
        {
          environment.systemPackages = [agenix.packages.${system}.default];
        }

        home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.users.martijn = import ../home/default.nix;
          home-manager.extraSpecialArgs = {inherit inputs outputs special-options;};
        }
      ]
      ++ extra-modules;
  }
