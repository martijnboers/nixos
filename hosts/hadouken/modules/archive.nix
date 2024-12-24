{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.archive;
in {
  options.hosts.archive = {
    enable = mkEnableOption "Bookmarks and archive webpages";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."archive.thuis".extraConfig = ''
        tls {
          issuer internal { ca hadouken }
         }
         @internal {
           remote_ip 100.64.0.0/10
         }
         handle @internal {
           reverse_proxy http://127.0.0.1:${toString config.services.shiori.port}
         }
      respond 403
    '';
    age.secrets.shiori.file = ../../../secrets/shiori.age;
    services.borgbackup.jobs.default.paths = [config.systemd.services.shiori.environment.SHIORI_DIR];

    services.shiori = {
      enable = true;
      port = 4354;
      environmentFile = config.age.secrets.shiori.path;
    };
  };
}
