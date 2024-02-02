{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "hadouken";

  imports = [
    ./modules/vaultwarden.nix
    ./modules/nextcloud.nix
    ./modules/headscale.nix
    ./modules/adguard.nix
    ./modules/caddy.nix
    ./modules/atuin.nix
    ./modules/plex.nix
  ];

  hosts.smb.enable = true;
  hosts.openssh.enable = true;
  hosts.caddy.enable = true;
  hosts.vaultwarden.enable = true;
  hosts.plex.enable = true;
  hosts.nextcloud.enable = true;
  hosts.headscale.enable = true;
  hosts.adguard.enable = true;

  hosts.borg = {
    enable = true;
    repository = "ssh://gak69wyz@gak69wyz.repo.borgbase.com/./repo";
  };

  hosts.resilio = {
    enable = true;
    name = "hadouken";
    ipaddress = "100.64.0.2";
  };

  # Sync zsh history
  hosts.atuin.enable = true;

  # Docker + QEMU
  hosts.virtualization.enable = true;

  # Enable general secrets
  hosts.secrets.hosts = true;

  # Needed for exit node headscale
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

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
