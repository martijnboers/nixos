{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.uptime-kuma;
in
{
  options.hosts.uptime-kuma = {
    enable = mkEnableOption "Uptime monitoring";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."uptime.thuis".extraConfig = ''
      import headscale
      import mtls

      handle @internal {
        reverse_proxy http://${config.services.uptime-kuma.settings.UPTIME_KUMA_HOST}:${config.services.uptime-kuma.settings.UPTIME_KUMA_PORT}
      }
      log {
          output discard
      }
      respond 403
    '';

    services.borgbackup.jobs.default.paths = [ "/var/lib/uptime-kuma" ];

    services.uptime-kuma = {
      enable = true;
      settings = {
        UPTIME_KUMA_HOST = "127.0.0.1";
        UPTIME_KUMA_PORT = "32578";
      };
    };
  };
}
