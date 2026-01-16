{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.proton;
  imapPort = 1143;
  smtpPort = 1025;
in
{
  options.hosts.proton = {
    enable = mkEnableOption "Proton bridge";
  };

  config = mkIf cfg.enable {
    services.protonmail-bridge.enable = true;

    # Keep user systemd-service running
    users.users.martijn.linger = true;

    systemd.user.services = {
      socat-proton-imap = {
        enable = true;
        description = "Socat forwarder for Proton Bridge IMAP";
        after = [ "protonmail-bridge.service" ];
        wants = [ "protonmail-bridge.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = 10;
          # Binds to Tailscale IP, forwards to Localhost
          ExecStart = "${lib.getExe pkgs.socat} TCP-LISTEN:${toString imapPort},fork,reuseaddr,bind=${config.hidden.tailscale_hosts.hadouken} TCP:127.0.0.1:${toString imapPort}";
        };
      };

      socat-proton-smtp = {
        enable = true;
        description = "Socat forwarder for Proton Bridge SMTP";
        after = [ "protonmail-bridge.service" ];
        wants = [ "protonmail-bridge.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = 10;
          # Binds to Tailscale IP, forwards to Localhost
          ExecStart = "${lib.getExe pkgs.socat} TCP-LISTEN:${toString smtpPort},fork,reuseaddr,bind=${config.hidden.tailscale_hosts.hadouken} TCP:127.0.0.1:${toString smtpPort}";
        };
      };
    };
  };
}
