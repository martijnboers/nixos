{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.uptime-kuma;
in {
  options.hosts.uptime-kuma = {
    enable = mkEnableOption "Uptime monitoring";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."uptime.thuis".extraConfig = ''
      tls internal
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://${config.services.uptime-kuma.settings.UPTIME_KUMA_HOST}:${config.services.uptime-kuma.settings.UPTIME_KUMA_PORT}
      }
      respond 403
    '';

    services.uptime-kuma = {
      enable = true;
      settings = {
        UPTIME_KUMA_HOST = "127.0.0.1";
        UPTIME_KUMA_PORT = "32578";
      };
    };
  };
}
