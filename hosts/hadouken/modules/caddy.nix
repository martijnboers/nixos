{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.caddy;
in
{
  options.hosts.caddy = {
    enable = mkEnableOption "Caddy base";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    services.caddy = {
      enable = true;
      package = pkgs.callPackage ../../../pkgs/xcaddy.nix {
        plugins = [
          "github.com/corazawaf/coraza-caddy/v2"
          "github.com/mholt/caddy-webdav"
        ];
      };

      globalConfig = ''
        metrics {
          per_host
        }
        servers {
          trusted_proxies static 100.64.0.0/10
          enable_full_duplex
        }
        pki {
         ca hadouken {
           name     hadouken
           # openssl genrsa -out root.key 4096
           # openssl req -x509 -new -nodes -key root.key -sha256 -days 3650 -out root.crt -config /etc/pki-root.cnf
           root {
             cert   ${../../../secrets/keys/hadouken.crt}
             key    ${config.age.secrets.hadouken-pki.path}
           }
         }
        }
        order coraza_waf first
        order webdav before file_server
      '';
      virtualHosts = {
        "webdav.thuis:80".extraConfig = ''
            @internal {
              remote_ip 100.64.0.0/10
            }
            handle @internal {
              route {
                rewrite /android /android/
                rewrite /notes /notes/
                webdav /android/* {
                  root /mnt/zwembad/app/android
                  prefix /android
                }
                webdav /notes/* {
                  root /mnt/zwembad/app/notes
                  prefix /notes
                }
                file_server
              }
            }
          respond 403
        '';
      };
    };

    age.secrets = {
      hadouken-pki = {
        file = ../../../secrets/hadouken-pki.age;
        owner = "caddy";
      };
    };

    systemd.services.caddy = {
      serviceConfig = {
        # Required to use ports < 1024
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        TimeoutStartSec = "5m";
      };
    };
  };
}
