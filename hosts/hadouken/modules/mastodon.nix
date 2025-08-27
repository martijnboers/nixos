{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.mastodon;
in
{
  options.hosts.mastodon = {
    enable = mkEnableOption "Mastodon feddy";
  };

  config = mkIf cfg.enable {
    systemd.services = {
      socat-mastodon-web =
        let
          socketPath = "/run/mastodon-web/web.socket";
        in
        {
          enable = true;
          description = "Socat for mastodon-web";
          after = [
            "network-online.target"
            "mastodon-web.service"
          ];
          wants = [
            "network-online.target"
            "mastodon-web.service"
          ];
          wantedBy = [ "multi-user.target" ];
          startLimitBurst = 10;
          startLimitIntervalSec = 600;
          serviceConfig = {
            Restart = "on-failure";
            ProtectSystem = "strict";
            RuntimeDirectory = [ socketPath ];
            ExecStart = "${lib.getExe pkgs.socat} TCP-LISTEN:5551,fork,reuseaddr,bind=${config.hidden.tailscale_hosts.hadouken} UNIX-CONNECT:${socketPath}";
            RestartSec = 10;
          };
        };
      socat-mastodon-streaming =
        let
          socketPath = "/run/mastodon-streaming/streaming-1.socket";
        in
        {
          enable = true;
          description = "Socat for mastodon-streaming";
          after = [
            "network-online.target"
            "mastodon-web.service"
          ];
          wants = [
            "network-online.target"
            "mastodon-web.service"
          ];
          wantedBy = [ "multi-user.target" ];
          startLimitBurst = 10;
          startLimitIntervalSec = 600;
          serviceConfig = {
            Restart = "on-failure";
            ProtectSystem = "strict";
            RuntimeDirectory = [ socketPath ];
            ExecStart = "${lib.getExe pkgs.socat} TCP-LISTEN:5552,fork,reuseaddr,bind=${config.hidden.tailscale_hosts.hadouken} UNIX-CONNECT:${socketPath}";
            RestartSec = 10;
          };
        };
    };

    services.mastodon = {
      enable = true;
      streamingProcesses = 1;
      # package = (
      #   pkgs.mastodon.override {
      #     pname = "glitch-soc";
      #     srcOverride = final.pkgs.callPackage ../../../pkgs/glitch-soc.nix { };
      #   }
      # );
      trustedProxy = "100.64.0.0/10,127.0.0.1";
      localDomain = "noisesfrom.space";
      configureNginx = false;
      smtp = {
        createLocally = false;
        fromAddress = "noreply@boers.email"; # required
      };
      extraEnvFiles = [ config.age.secrets.mastodon.path ];
      extraConfig = {
        SINGLE_USER_MODE = "true";
        MAX_TOOT_CHARS = "1000"; # yeey for glitch-soc

        S3_ENABLED = "true";
        S3_BUCKET = "mastodon";
        S3_REGION = "thuis";
        S3_ENDPOINT = "https://storage.boers.email";
        S3_HOSTNAME = "storage.boers.email";
      };
      mediaAutoRemove = {
        enable = true;
        olderThanDays = 14;
      };
    };

    age.secrets = {
      fedifetcher.file = ../../../secrets/fedifetcher.age;
      mastodon.file = ../../../secrets/mastodon.age;
    };

    # Backfill comments automaticly
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
