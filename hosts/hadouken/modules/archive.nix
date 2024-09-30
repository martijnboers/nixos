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
         tls internal
         @internal {
           remote_ip 100.64.0.0/10
         }
         handle @internal {
           reverse_proxy http://127.0.0.1:${toString config.services.shiori.port}
         }
      respond 403
    '';
    services.borgbackup.jobs.default.paths = [config.systemd.services.shiori.environment.SHIORI_DIR];
    services.shiori = {
        enable = true;
	package = pkgs.unstable.shiori; # stable doesn't work with latest browser plugin
        port = 4354;
    };
  };
}
