{ pkgs, lib, ... }:
{
  networking.hostName = "suzaku";

  imports = [ ./modules/caddy.nix ];

  hosts.caddy.enable = true;
  nix-mineral.enable = false;

  environment.systemPackages = [
    pkgs.raspberrypi-eeprom
    pkgs.ubootTools
  ];

  users.users.martijn = {
    hashedPasswordFile = lib.mkForce null;
    hashedPassword = "$y$j9T$VQL/82faMlZSrWg9SefdB/$RQpwhho.v0avZJcjate9yXdzDxVRdBBXeui7ch5XYm9";
  };

  # hosts.borg = {
  #   enable = true;
  #   repository = "ssh://aebp8i08@aebp8i08.repo.borgbase.com/./repo";
  # };

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
      "*@10.10.0.0/24"
    ];
  };

  nix.settings.trusted-users = [ "martijn" ]; # allows for remote push

  # Enable tailscale network
  hosts.tailscale.enable = true;

  # Server defaults
  hosts.server.enable = true;
}
