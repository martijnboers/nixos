{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.acme;
in
{
  options.hosts.acme = {
    enable = mkEnableOption "Acme config";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nss ];

    services.caddy = {
      enable = true;
      globalConfig = ''
        skip_install_trust
        pki {
            ca acme {
              name acme
            }
            ca plebs4gold {
        	name plebas4gold
        	intermediate_cn plebs4cash
        	root {
        	  format pem_file
        	  key ${config.age.secrets.plebs4diamondspem.path}
        	  cert ${../../../secrets/keys/plebs4diamonds.crt}
        	}
            }
        }
      '';
      virtualHosts = {
        "acme.thuis" = {
          extraConfig = ''
            tls {
              issuer internal { ca acme }
            }
            acme_server {
              ca plebs4gold
              resolvers 100.100.100.100
              allow {
                domains *.thuis 
              }
            }
          '';
        };

      };
    };
    age.secrets = {
      plebs4diamondspem = {
        file = ../../../secrets/plebs4diamondspem.age;
        owner = "caddy";
      };
    };
  };
}
