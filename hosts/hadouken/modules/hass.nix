{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.hass;
in {
  options.hosts.hass = {
    enable = mkEnableOption "Home assistant server";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."hass.thuis.plebian.nl".extraConfig = ''
      tls internal
      reverse_proxy http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}
    '';
    services.borgbackup.jobs.default.paths = ["${config.services.home-assistant.configDir}"];
    services.home-assistant = {
      enable = true;
      config = {
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
        ];
      };
        default_config = {};
        homeassistant = {
          name = "Thuis";
          unit_system = "metric";
          temperature_unit = "C";
        };
      };
    };
  };
}
