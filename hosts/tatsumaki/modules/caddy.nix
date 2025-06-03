{
  config,
  lib,
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
      globalConfig = ''
        servers {
          trusted_proxies static 100.64.0.0/10
          enable_full_duplex
        }
        pki {
         ca tatsumaki {
           name     tatsumaki
           root {
             cert   ${../../../secrets/keys/tatsumaki.crt}
             key    ${config.age.secrets.tatsumaki-pki.path}
           }
         }
        }
      '';
      extraConfig = ''
        (headscale) {
          @internal remote_ip 100.64.0.0/10
          tls {
            issuer internal { ca tatsumaki }
          }
        }
      '';
    };

    age.secrets = {
      tatsumaki-pki = {
        file = ../../../secrets/tatsumaki-pki.age;
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
