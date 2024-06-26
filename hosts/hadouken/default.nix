{
  lib,
  pkgs,
  config,
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
    ./modules/nextcloud.nix
    ./modules/headscale.nix
    ./modules/cyberchef.nix
    ./modules/keycloak.nix
    ./modules/mastodon.nix
    ./modules/endlessh.nix
    ./modules/fail2ban.nix
    ./modules/adguard.nix
    ./modules/conduit.nix
    ./modules/caddy.nix
    ./modules/atuin.nix
    ./modules/pgrok.nix
    ./modules/plex.nix
    ./modules/hass.nix
    ./modules/zfs.nix
  ];

  hosts.smb.enable = true;
  hosts.caddy.enable = true;
  hosts.vaultwarden.enable = true;
  hosts.plex.enable = true;
  hosts.nextcloud.enable = true;
  hosts.headscale.enable = true;
  hosts.adguard.enable = true;
  hosts.hass.enable = true;
  hosts.tailscale.enable = true;
  hosts.keycloak.enable = true;
  hosts.pgrok.enable = true;
  hosts.cyberchef.enable = true;
  hosts.monitoring.enable = true;
  hosts.endlessh.enable = true;
  hosts.conduit.enable = true;
  hosts.mastodon.enable = true;
  hosts.fail2ban.enable = true;

  # Right order of headscale operations for startup
  systemd.services.headscale = {
    after = ["keycloak.service"];
    requires = ["keycloak.service"];
    startLimitBurst = 10;
    startLimitIntervalSec = 600;
    serviceConfig = defaultRestart;
  };
  systemd.services.tailscaled = {
    after = ["headscale.service"];
    requires = ["headscale.service"];
    startLimitBurst = 10;
    startLimitIntervalSec = 600;
    serviceConfig = defaultRestart;
  };
  systemd.services.sshd = {
    after = ["tailscaled.service"];
    requires = ["tailscaled.service"];
    serviceConfig = defaultRestart;
  };
  systemd.services.resilio = {
    after = ["tailscaled.service"];
    requires = ["tailscaled.service"];
    startLimitBurst = 10;
    startLimitIntervalSec = 600;
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

  # immich requires docker 25
  virtualisation.docker.package = pkgs.docker_25;

  hosts.auditd = {
    enable = true;
    rules = [
      "-w /home/martijn/.ssh -p rwa -k ssh_file_access"
      "-w /home/martijn/Nix -p rwa -k nix_config_changes"
      "-a exit,always -F arch=b64 -S execve -k program_run"
    ];
  };

  hosts.resilio = {
    enable = true;
    name = "hadouken";
    ipaddress = "100.64.0.2";
  };

  hosts.openssh = {
    enable = true;
    ipaddress = "100.64.0.2";
  };

  # Sync zsh history
  hosts.atuin.enable = true;

  # Docker + QEMU
  hosts.virtualization.enable = true;

  # Needed for exit node headscale
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  environment.systemPackages = with pkgs; [pgrok pgrok.server unstable.immich-go];

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
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

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
