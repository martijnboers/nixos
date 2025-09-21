{ lib, ... }:
let
  defaultRestart = {
    RestartSec = 10;
  };
in
{
  networking = {
    hostName = "hadouken";
    hostId = "1b936a2a";
  };

  imports = [
    ./modules/vaultwarden.nix
    ./modules/monitoring.nix
    ./modules/detection.nix
    ./modules/mastodon.nix
    ./modules/detection.nix
    ./modules/syncthing.nix
    ./modules/paperless.nix
    ./modules/microbin.nix
    ./modules/calendar.nix
    ./modules/database.nix
    ./modules/storage.nix
    ./modules/pingvin.nix
    ./modules/archive.nix
    ./modules/matrix.nix
    ./modules/immich.nix
    ./modules/shares.nix
    ./modules/caddy.nix
    ./modules/atuin.nix
    ./modules/plex.nix
    ./modules/llm.nix
  ];

  hosts.shares.enable = true;
  hosts.caddy.enable = true;
  hosts.vaultwarden.enable = true;
  hosts.plex.enable = true;
  hosts.tailscale.enable = true;
  hosts.monitoring.enable = true;
  hosts.matrix.enable = true;
  hosts.mastodon.enable = true;
  hosts.llm.enable = true;
  hosts.microbin.enable = true;
  hosts.archive.enable = true;
  hosts.changedetection.enable = true;
  hosts.immich.enable = true;
  hosts.prometheus.enable = true;
  hosts.calendar.enable = true;
  hosts.database.enable = true;
  hosts.atuin.enable = true;
  hosts.pingvin.enable = true;
  hosts.paperless.enable = true;

  hosts.adguard = {
    enable = true;
    domain = "dns";
  };

  users = {
    groups.multimedia = { };
    users = {
      syncthing.extraGroups = [ "multimedia" ];
      plex.extraGroups = [ "multimedia" ];
      martijn.extraGroups = [ "multimedia" ];
    };
  };

  systemd.services.loki = {
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    serviceConfig = defaultRestart;
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://gak69wyz@gak69wyz.repo.borgbase.com/./repo";
    paths = [ "/mnt/zwembad/app" ];
  };

  hosts.syncthing = {
    enable = true;
    name = "hadouken";
  };

  # Heat management intel cpu
  services.thermald.enable = true;

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
      "*@10.10.0.0/24"
    ];
  };

  # Server defaults
  hosts.server.enable = true;

  # Allow network access when building
  # https://mdleom.com/blog/2021/12/27/caddy-plugins-nixos/#xcaddy
  nix.settings.sandbox = false;

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false;
      extraPools = [
        "zwembad"
        "garage"
      ];
    };

    # Silent Boot
    # https://wiki.archlinux.org/title/Silent_boot
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
