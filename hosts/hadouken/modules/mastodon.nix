{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.mastodon;
  mediaRoot = "/mnt/zwembad/games/mastodon/";
in
{
  options.hosts.mastodon = {
    enable = mkEnableOption "Mastodon feddy";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."mastodon.thuis".extraConfig = ''
      tls {
        issuer internal { ca hadouken }
      }
      root * ${mediaRoot}
      file_server 
    '';

    systemd.services = {
      socat-mastodon-web =
        let
          socketPath = "/run/mastodon-web/web.socket";
        in
        {
          enable = true;
          description = "Socat for mastodon-web";
          after = [ "mastodon.target" ];
          wants = [ "mastodon.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Restart = "on-failure";
            ProtectSystem = "strict";
            RuntimeDirectory = [ socketPath ];
            ExecStart = "${lib.getExe pkgs.socat} TCP-LISTEN:5551,fork,reuseaddr,bind=100.64.0.2 UNIX-CONNECT:${socketPath}";
          };
        };
      socat-mastodon-streaming =
        let
          socketPath = "/run/mastodon-streaming/streaming-1.socket";
        in
        {
          enable = true;
          description = "Socat for mastodon-streaming";
          after = [ "mastodon.target" ];
          wants = [ "mastodon.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Restart = "on-failure";
            ProtectSystem = "strict";
            RuntimeDirectory = [ socketPath ];
            ExecStart = "${lib.getExe pkgs.socat} TCP-LISTEN:5552,fork,reuseaddr,bind=100.64.0.2 UNIX-CONNECT:${socketPath}";
          };
        };
    };

    # Allow access of mediaRoot
    systemd.services.caddy.serviceConfig.ReadWriteDirectories = [ mediaRoot ];
    systemd.services.mastodon-web.serviceConfig.ReadWriteDirectories = [ mediaRoot ];
    systemd.services.mastodon-media-auto-remove.serviceConfig.ReadWriteDirectories = [ mediaRoot ];
    users.users.caddy.extraGroups = [ "mastodon" ];

    services.mastodon = {
      enable = true;
      streamingProcesses = 1;
      trustedProxy = "100.64.0.0/10,127.0.0.1";
      localDomain = "noisesfrom.space";
      configureNginx = false;
      smtp = {
        createLocally = false;
        fromAddress = "noreply@plebian.nl"; # required
      };
      extraConfig = {
        SINGLE_USER_MODE = "true";
        PAPERCLIP_ROOT_PATH = mediaRoot;
      };
      mediaAutoRemove = {
        enable = true;
        olderThanDays = 14;
      };
    };

    # Backfill comments automaticly
    age.secrets.fedifetcher.file = ../../../secrets/fedifetcher.age;

    systemd.services.fedifetcher = {
      description = "FediFetcher";
      wants = [
        "mastodon-web.service"
        "mastodon-wait-for-available.service"
      ];
      after = [
        "mastodon-web.service"
        "mastodon-wait-for-available.service"
      ];
      startAt = "*-*-* 05..23:*:00/20"; # every 20 minutes between 6 and 23

      serviceConfig = {
        Type = "oneshot";
        DynamicUser = true;
        StateDirectory = "fedifetcher";
        LoadCredential = "config.json:${config.age.secrets.fedifetcher.path}";
        ExecStart = "${lib.getExe pkgs.fedifetcher} --state-dir=/var/lib/fedifetcher --config=%d/config.json";
      };
    };
  };
}
