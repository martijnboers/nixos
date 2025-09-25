{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.notifications;
  mail-user = "smtp-gotify";
in
{
  options.hosts.notifications = {
    enable = mkEnableOption "Gotify + smtp bridge";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."notifications.thuis".extraConfig = ''
      import headscale
      handle @internal {
        reverse_proxy http://localhost:${toString config.services.gotify.environment.GOTIFY_SERVER_PORT}
      }
      respond 403
    '';

    services.borgbackup.jobs.default.paths = [ config.services.gotify.stateDirectoryName ];

    age.secrets.mailrise = {
      file = ../../../secrets/mailrise.age;
      owner = mail-user;
    };

    users.users.${mail-user} = {
      isSystemUser = true;
      group = mail-user;
    };
    users.groups.${mail-user} = { };

    systemd.services.smtp-gotify = {
      description = "SMTP to Gotify Bridge";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.smtp-gotify}/bin/smtp-gotify";
        User = mail-user;
        Group = mail-user;

        # Set environment variables from the module's options
        Environment = [
          "SG_SMTP_LISTEN=0.0.0.0:8025"
          "GOTIFY_URL=https://notifications.thuis"
        ];
        EnvironmentFile = config.age.secrets.mailrise.path;

        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
      };
    };

    services.gotify = {
      enable = true;
      environment.GOTIFY_SERVER_PORT = 2230;
    };
  };
}
