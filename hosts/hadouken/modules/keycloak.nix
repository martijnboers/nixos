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

    age.secrets.caddy.file = ../secrets/caddy.age;

    services.keycloak = {
      enable = true;
      database = {
        # database will be automatically created by the keycloak module
        type = "postgresql";
        passwordFile = config.age.secrets.keycloak.path;
      };
      settings = {
        hostname = "auth.plebian.nl";
        proxy = "edge";
        http-host = "127.0.0.1";
        http-port = 3345;
      };
    };
  };
}
