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
    services.caddy.virtualHosts."auth.plebian.nl".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.keycloak.settings.http-port}
    '';
    services.caddy.virtualHosts."auth.thuis.plebian.nl".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.keycloak.settings.http-port}
    '';

    age.secrets.keycloak.file = ../../../secrets/keycloak.age;

    services.keycloak = {
      enable = true;
      database = {
        type = "postgresql";
        passwordFile = config.age.secrets.keycloak.path;
      };
      settings = {
        hostname = "auth.plebian.nl";
        proxy = "edge";
        http-host = "0.0.0.0";
        http-port = 3345;
      };
    };
  };
}
