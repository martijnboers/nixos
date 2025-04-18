{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.mastodon;
in {
  options.hosts.mastodon = {
    enable = mkEnableOption "Mastodon feddy";
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [80 443];
    };

    services.caddy.virtualHosts."noisesfrom.space".extraConfig = ''
      @internal {
          remote_ip 100.64.0.0/10
      }

      coraza_waf {
          load_owasp_crs
          directives `
              Include @coraza.conf-recommended
              SecRuleEngine On
          `
      }

      handle_path /system/* {
          file_server * {
              root /var/lib/mastodon/public-system
          }
      }

      handle /api/v1/streaming/* {
          reverse_proxy unix//run/mastodon-streaming/streaming.socket
      }

      route * {
          file_server * {
              root ${pkgs.mastodon}/public
              pass_thru
          }
          reverse_proxy * unix//run/mastodon-web/web.socket
      }

      handle_errors {
          root * ${pkgs.mastodon}/public
          rewrite 500.html
          file_server
      }

      encode gzip

      header /* {
          Strict-Transport-Security "max-age=31536000;"
      }

      header /emoji/* Cache-Control "public, max-age=31536000, immutable"
      header /packs/* Cache-Control "public, max-age=31536000, immutable"
      header /system/accounts/avatars/* Cache-Control "public, max-age=31536000, immutable"
      header /system/media_attachments/files/* Cache-Control "public, max-age=31536000, immutable"
    '';
    # Caddy requires file and socket access
    users.users.caddy.extraGroups = ["mastodon"];

    # Caddy systemd unit needs readwrite permissions to /run/mastodon-web
    systemd.services.caddy.serviceConfig.ReadWriteDirectories = lib.mkForce ["/var/lib/caddy" "/run/mastodon-web"];

    services.postgresqlBackup = {
      enable = true;
      databases = ["mastodon"];
    };
    services.borgbackup.jobs.default.paths = [config.services.postgresqlBackup.location];

    services.mastodon = {
      enable = true;
      streamingProcesses = 7;
      localDomain = "noisesfrom.space";
      trustedProxy = "100.64.0.1"; # shoryuken
      configureNginx = false;
      smtp = {
        createLocally = false;
        fromAddress = "noreply@plebian.nl"; # required
      };
      extraConfig.SINGLE_USER_MODE = "true";
      mediaAutoRemove = {
        enable = true;
        olderThanDays = 14;
      };
    };

    # Backfill comments automaticly
    age.secrets.fedifetcher.file = ../../../secrets/fedifetcher.age;

    systemd.services.fedifetcher = {
      description = "FediFetcher";
      wants = ["mastodon-web.service" "mastodon-wait-for-available.service"];
      after = ["mastodon-web.service" "mastodon-wait-for-available.service"];
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
