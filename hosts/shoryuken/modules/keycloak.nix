{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.keycloak;
in {
  options.hosts.keycloak = {
    enable = mkEnableOption "Provide OIDC";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."auth.donder.cloud".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.keycloak.settings.http-port}
    '';

    age.secrets.keycloak.file = ../../../secrets/keycloak.age;
    services.postgresql.enable = true;

    environment = {
      systemPackages = with pkgs; [
        keycloak
      ];
      # No x installed on host
      noXlibs = false;
    };

    services.keycloak = {
      enable = true;
      database = {
        type = "postgresql";
        passwordFile = config.age.secrets.keycloak.path;
      };
      settings = {
        hostname = "auth.donder.cloud";
        proxy = "edge";
        http-host = "0.0.0.0";
        http-port = 3345;
      };
    };
  };
}
