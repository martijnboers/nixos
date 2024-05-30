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
      hmace.file = ../../../secrets/hmace.age;
      invidious.file = ../../../secrets/invidious.age;
    };

    services.postgresqlBackup = {
      enable = true;
      databases = ["invidious"];
    };

    services.borgbackup.jobs.default.paths = [config.services.postgresqlBackup.location];

    services.invidious = {
      enable = true;
      domaine = "videos.thuis.plebian.nl";
      passwordFile = config.age.secrets.invidious.path;
      hmacKeyFile = config.age.secrets.hmac.path;
    };
  };
}
