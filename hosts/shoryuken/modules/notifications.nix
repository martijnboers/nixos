{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.notifications;
in {
  options.hosts.notifications = {
    enable = mkEnableOption "Gotify + smtp bridge";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."notifications.thuis".extraConfig = ''
      tls internal
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://localhost:${toString config.services.gotify.port}
      }
      log {
          output discard
      }
      respond 403
    '';

    services.borgbackup.jobs.default.paths = [config.services.gotify.stateDirectoryName];
    age.secrets.gotify.file = ../../../secrets/gotify.age;

    systemd.services.smtp-gotify = {
      after = ["network.target"];
      description = "SMTP bridge gotify";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${getExe pkgs.smtp-gotify} --smtp-listen 0.0.0.0:2525 --gotify-url https://notifications.thuis/";
        EnvironmentFile = config.age.secrets.gotify.path;
        TimeoutStartSec = 600;
        Restart = "on-failure";
        NoNewPrivileges = true;
      };
    };

    services.gotify = {
      enable = true;
      port = 2230;
    };
  };
}
