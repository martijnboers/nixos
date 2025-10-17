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
    services.caddy = {
      enable = true;
      package = pkgs.callPackage ../../../pkgs/xcaddy.nix {
        plugins = [
          "github.com/corazawaf/coraza-caddy/v2"
          "github.com/mholt/caddy-webdav"
        ];
      };

      extraConfig = ''
        (headscale) {
          @internal remote_ip 100.64.0.0/10
          tls {
            ca https://acme.thuis/acme/plebs4gold/directory
          }
        }
        (mtls) {
          tls {
            client_auth {
              mode require_and_verify
              trust_pool file {
        	pem_file ${../../../secrets/keys/plebs4gold.crt}
              }
            }
          }
        }
      '';

      globalConfig = ''
        metrics {
          per_host
        }
        servers {
          trusted_proxies static 100.64.0.0/10
          enable_full_duplex
        }

        order coraza_waf first
        order webdav before file_server
      '';
      virtualHosts = {
        "webdav.thuis:80".extraConfig = ''
          import headscale
          handle @internal {
            route {
              basic_auth {
                martijn $2a$14$ASOmj.jZv9cvR0W5E26UkOpCD7fjCWhfEKnI0YKUChqDsfx9FqR/O
              }
              rewrite /android /android/
              webdav /android/* {
                root /mnt/zwembad/app/android
                prefix /android
              }
              rewrite /notes /notes/
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
