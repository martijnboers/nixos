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
          ca plebs4gold {
            name plebs4gold
            intermediate_cn plebs4cash
            root {
              key ${config.age.secrets.plebs4gold.path}
              cert ${../../../secrets/keys/plebs4gold.crt}
            }
          }
        }
      '';
      virtualHosts = {
        "acme.thuis" = {
          extraConfig = ''
            tls {
              issuer internal { ca plebs4gold }
            }
            acme_server {
              ca plebs4gold
              allow {
                domains *.thuis 
              }
            }
          '';
        };

      };
    };
    age.secrets = {
      plebs4gold = {
        file = ../../../secrets/plebs4gold.age;
        owner = "caddy";
      };
    };
  };
}
