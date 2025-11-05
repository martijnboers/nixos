{ pkgs, ... }:
{
  networking.hostName = "tenshin";

  imports = [
    ./modules/cyberchef.nix
    ./modules/ittools.nix
    ./modules/ladder.nix
    ./modules/caddy.nix
    ./modules/hass.nix
    ./modules/ntp.nix
  ];

  hosts.caddy.enable = true;
  hosts.cyberchef.enable = true;
  hosts.it-tools.enable = true;
  hosts.prometheus.enable = true;
  hosts.hass.enable = true;
  hosts.ntp.enable = true;
  hosts.ladder.enable = true;

  hosts.auditd.enable = false;
  nix-mineral.enable = false;

  environment.systemPackages = [
    pkgs.raspberrypi-eeprom
    pkgs.ubootTools
  ];

  hosts.borg = {
    enable = true;
    repository = "ssh://aebp8i08@aebp8i08.repo.borgbase.com/./repo";
  };

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

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
}
