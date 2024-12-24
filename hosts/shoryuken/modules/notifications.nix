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
      tls {
        issuer internal { ca shoryuken }
      }
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://localhost:${toString config.services.gotify.environment.GOTIFY_SERVER_PORT}
      }
      log {
          output discard
      }
      respond 403
    '';

    services.borgbackup.jobs.default.paths = [config.services.gotify.stateDirectoryName];
    age.secrets.mailrise.file = ../../../secrets/mailrise.age;

    systemd.services.mailrise = let
      configFile = pkgs.writeText "mailrise_config.yml" ''
        configs:
          '*@*':
            urls:
            - !env_var GOTIFY_URL
      '';
    in {
      wantedBy = ["multi-user.target"];
      description = "SMTP bridge apprise";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${getExe pkgs.mailrise} ${configFile}";
        EnvironmentFile = config.age.secrets.mailrise.path;
        TimeoutStartSec = 600;
        Restart = "on-failure";
        NoNewPrivileges = true;
      };
    };

    services.gotify = {
      enable = true;
      environment.GOTIFY_SERVER_PORT = 2230;
    };
  };
}
