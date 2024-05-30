{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.invidious;
in {
  options.hosts.invidious = {
    enable = mkEnableOption "Enable youtube client";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."videos.thuis.plebian.nl".extraConfig = ''
         tls internal
         @internal {
           remote_ip 100.64.0.0/10
         }
         handle @internal {
           reverse_proxy http://localhost:${toString config.services.invidious.port}
         }
      respond 403
    '';

    age.secrets = {
      hmac = {
        file = ../../../secrets/hmac.age;
        mode = "0644";
      };
      invidious = {
        file = ../../../secrets/invidious.age;
        mode = "444";
      };
    };

    services.postgresqlBackup = {
      enable = true;
      databases = ["invidious"];
    };

    services.invidious = {
      enable = true;
      domain = "videos.thuis.plebian.nl";
      database.passwordFile = config.age.secrets.invidious.path;
      hmacKeyFile = config.age.secrets.hmac.path;
      database.createLocally = true;
      settings = {
        admins = ["martijn"];
        quality = "dash";
        quality_dash = "best";
        db = {
          user = "invidious";
          dbname = "invidious";
        };
      };
    };
  };
}
