{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "hadouken";

  imports = [
    ./modules/atuin.nix
    ./modules/caddy.nix
    ./modules/vaultwarden.nix
    ./modules/coredns.nix
    ./modules/plex.nix
    ./modules/nextcloud.nix
    ./modules/headscale.nix
  ];

  hosts.smb.enable = true;
  hosts.openssh.enable = true;
  hosts.caddy.enable = true;
  hosts.vaultwarden.enable = true;
  hosts.plex.enable = true;
  hosts.coredns.enable = true;
  hosts.nextcloud.enable = true;
  hosts.headscale.enable = true;

  hosts.borg = {
    enable = true;
    repository = "ssh://gak69wyz@gak69wyz.repo.borgbase.com/./repo";
  };

  hosts.syncthing = {
    enable = true;
    ipaddress = "100.64.0.2";
  };

  hosts.resilio = {
    enable = true;
    name = "hadouken";
    ipaddress = "100.64.0.2";
  };

  services.syncthing.settings.folders = {
    "Obsidian" = {
      path = "~/Sync/Obsidian";
      devices = ["glassdoor" "phone" "lapdance" "hadouken"];
    };
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
