{ config, ... }:
{
  networking.hostName = "tenshin";

  imports = [
    ./modules/cyberchef.nix
    ./modules/adguard.nix
    ./modules/search.nix
    ./modules/cinny.nix
    ./modules/caddy.nix
    ./modules/hass.nix
  ];

  hosts.adguard.enable = true;
  hosts.caddy.enable = true;
  hosts.cinny-web.enable = true;
  hosts.search.enable = true;
  hosts.cyberchef.enable = true;
  hosts.prometheus.enable = true;
  hosts.hass.enable = true;

  # SDR
  hardware.rtl-sdr.enable = true;

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
