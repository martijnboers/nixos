{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.seafile;
in {
  options.hosts.seafile = {
    enable = mkEnableOption "Seafile server";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."sea.plebian.nl".extraConfig = ''
      reverse_proxy unix//run/seahub/gunicorn.sock

      handle_path /seafhttp/* {
        reverse_proxy http://127.0.0.1:${toString config.services.seafile.seafileSettings.fileserver.port}
      }
    '';
    services.seafile = {
      enable = true;
      adminEmail = "seafile@plebian.nl";
      seafileSettings.fileserver = {
        host = "0.0.0.0";
        port = 2734;
      };
      ccnetSettings.General = {
        SERVICE_URL = "https://sea.plebian.nl";
        FILE_SERVER_ROOT = "https://sea.plebian.nl/seafhttp";
      };
      dataDir = "/mnt/zwembad/app/seafile";
    };
  };
}
