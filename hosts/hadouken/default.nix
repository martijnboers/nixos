{
  pkgs,
  config,
  lib,
  ...
}: let
  defaultRestart = {
    RestartSec = 10;
  };
in {
  networking.hostName = "hadouken";
  networking.hostId = "1b936a2a";

  imports = [
    ./modules/vaultwarden.nix
    ./modules/monitoring.nix
    ./modules/cyberchef.nix
    ./modules/mastodon.nix
    ./modules/wordpress.nix
    ./modules/fail2ban.nix
    ./modules/microbin.nix
    ./modules/radicale.nix
    ./modules/bincache.nix
    ./modules/adguard.nix
    ./modules/seafile.nix
    ./modules/storage.nix
    ./modules/archive.nix
    ./modules/ollama.nix
    ./modules/matrix.nix
    ./modules/immich.nix
    ./modules/search.nix
    ./modules/caddy.nix
    ./modules/atuin.nix
    ./modules/pgrok.nix
    ./modules/cinny.nix
    ./modules/plex.nix
    ./modules/sync.nix
    ./modules/hass.nix
  ];

  hosts.smb.enable = true;
  hosts.caddy.enable = true;
  hosts.vaultwarden.enable = true;
  hosts.plex.enable = true;
  hosts.seafile.enable = true;
  hosts.adguard.enable = true;
  hosts.hass.enable = true;
  hosts.tailscale.enable = true;
  hosts.pgrok.enable = true;
  hosts.cyberchef.enable = true;
  hosts.monitoring.enable = true;
  hosts.matrix.enable = true;
  hosts.mastodon.enable = true;
  hosts.fail2ban.enable = true;
  hosts.ollama.enable = true;
  hosts.wordpress.enable = true;
  hosts.microbin.enable = true;
  hosts.sync.enable = true;
  hosts.archive.enable = true;
  hosts.binarycache.enable = true;
  hosts.search.enable = true;
  hosts.cinny-web.enable = true;
  hosts.immich.enable = true;
  hosts.prometheus.enable = true;
  hosts.radicale.enable = true;

  systemd.services.sshd = {
    after = ["tailscaled.service"];
    requires = ["tailscaled.service"];
    serviceConfig = defaultRestart;
  };
  systemd.services.loki = {
    after = ["tailscaled.service"];
    requires = ["tailscaled.service"];
    serviceConfig = defaultRestart;
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://gak69wyz@gak69wyz.repo.borgbase.com/./repo";
    paths = ["/mnt/zwembad/app"];
  };

  hosts.auditd = {
    enable = true;
    rules = [
      "-w /home/martijn/.ssh -p rwa -k ssh_file_access"
      "-w /home/martijn/Nix -p rwa -k nix_config_changes"
      "-a exit,always -F arch=b64 -S execve -k program_run"
    ];
  };

  hosts.syncthing = {
    enable = true;
    name = "hadouken";
  };

  # Don't use own bincache, only upstream
  nix.settings.substituters = lib.mkForce ["https://cache.nixos.org"];

  hosts.openssh.enable = true;

  # Server for atuin
  hosts.atuin.enable = true;

  environment.systemPackages = with pkgs; [pgrok pgrok.server immich-go];

  # Allow network access when building
  # https://mdleom.com/blog/2021/12/27/caddy-plugins-nixos/#xcaddy
  nix.settings.sandbox = false;

  # Bootloader.
  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = ["zfs"];
    zfs = {
      forceImportRoot = false;
      extraPools = ["zwembad" "garage"];
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
    initrd.verbose = false;
  };
}
