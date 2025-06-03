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
        import headscale
        coraza_waf {
          load_owasp_crs
          directives `
            Include @coraza.conf-recommended
            SecRuleEngine On
          `
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
