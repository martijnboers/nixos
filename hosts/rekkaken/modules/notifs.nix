{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.notifications;
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
    age.secrets.mailrise.file = ../../../secrets/mailrise.age;

    systemd.services.smtp-gotify = {
      description = "SMTP to Gotify Bridge";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.smtp-gotify}/bin/smtp-gotify";
        DynamicUser = true;
        Environment = [
          "SG_SMTP_LISTEN=0.0.0.0:8025"
          "GOTIFY_URL=https://notifications.thuis"
        ];
        EnvironmentFile = config.age.secrets.mailrise.path;
        Restart = "on-failure";
        RestartSec = "5s";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
      };
    };

    services.gotify = {
      enable = true;
      environment.GOTIFY_SERVER_PORT = 2230;
    };
  };
}
