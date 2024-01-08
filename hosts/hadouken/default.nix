{
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "hadouken";

  imports = [
    ./modules/atuin.nix
    ./modules/caddy.nix
    ./modules/resilio.nix
    ./modules/vaultwarden.nix
    ./modules/coredns.nix
    ./modules/plex.nix
    ./modules/nextcloud.nix
  ];

  hosts.smb.enable = true;
  hosts.openssh.enable = true;
  hosts.caddy.enable = true;
  hosts.vaultwarden.enable = true;
  hosts.plex.enable = true;
  hosts.coredns.enable = true;
  hosts.resilio.enable = true;
  hosts.nextcloud.enable = true;

  # Sync zsh history
  hosts.atuin.enable = true;

  # Docker + QEMU
  hosts.virtualization.enable = true;

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
