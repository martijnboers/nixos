{
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "hadouken";

  imports = [
    ./modules/caddy.nix
    ./modules/vaultwarden.nix
    ./modules/coredns.nix
    ./modules/plex.nix
  ];

  # Enable share
  hosts.smb.enable = true;

  # Enable ssh for host
  hosts.openssh.enable = true;

  # Websites
  hosts.caddy.enable = true;

  # Vaultwarden
  hosts.vaultwarden.enable = true;

  # Plex
  hosts.plex.enable = true;

  # Custom DNS records
  hosts.coredns.enable = true;

  # Bootloader.
  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Silent Boot
    # https://wiki.archlinux.org/title/Silent_boot
    kernelParams = [
      "quiet"
      "splash"
      "vga=current"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    consoleLogLevel = 0;
    # https://github.com/NixOS/nixpkgs/pull/108294
    initrd = {
      verbose = false;
    };
  };
}
