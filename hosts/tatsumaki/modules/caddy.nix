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
           # openssl genrsa -out root.key 4096
           # openssl req -x509 -new -nodes -key root.key -sha256 -days 3650 -out root.crt -config /etc/pki-root.cnf
           root {
             cert   ${../../../secrets/keys/tatsumaki.crt}
             key    ${config.age.secrets.tatsumaki-pki.path}
           }
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
