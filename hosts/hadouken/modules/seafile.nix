{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.seafile;
in
{
  options.hosts.seafile = {
    enable = mkEnableOption "Seafile server";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "seaf.thuis".extraConfig = ''
        tls {
          issuer internal { ca hadouken }
        }
        @internal {
          remote_ip 100.64.0.0/10
        }
        handle @internal {
         reverse_proxy unix//run/seahub/gunicorn.sock

         handle_path /seafhttp/* {
           reverse_proxy http://127.0.0.1:${toString config.services.seafile.seafileSettings.fileserver.port}
         }
        }
        respond 403
      '';
    };

    services.seafile = {
      enable = true;
      adminEmail = "seafile@plebian.nl";
      seafileSettings.fileserver = {
        host = "0.0.0.0";
        port = 2734;
      };
      initialAdminPassword = "why-is-this-a-required-property";
      ccnetSettings.General = {
        SERVICE_URL = "https://sea.plebian.nl";
        FILE_SERVER_ROOT = "https://sea.plebian.nl/seafhttp";
      };
      dataDir = "/mnt/zwembad/app/seafile";
    };
  };
}
