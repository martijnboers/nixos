{
  config,
  lib,
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
      respond 403
    '';

    services.borgbackup.jobs.default.paths = [config.services.gotify.stateDirectoryName];

    services.gotify = {
      enable = true;
      port = 2230;
    };
  };
}
