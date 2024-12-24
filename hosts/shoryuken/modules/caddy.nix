{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.caddy;
in {
  options.hosts.caddy = {
    enable = mkEnableOption "Caddy base";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.caddy = {
      enable = true;
      globalConfig = ''
        pki {
          ca shoryuken {
            name     shoryuken
            # openssl genrsa -out root.key 4096
            # openssl req -x509 -new -nodes -key root.key -sha256 -days 3650 -out root.crt -config /etc/pki-root.cnf
            root {
              cert   ${../../../nixos/keys/shoryuken.crt}
              key    ${config.age.secrets.shoryuken-pki.path}
            }
          }
        }
      '';
      virtualHosts."donder.cloud".extraConfig = ''
        respond "🌩️"
      '';
    };

    age.secrets = {
      shoryuken-pki = {
        file = ../../../secrets/shoryuken-pki.age;
        owner = "caddy";
      };
    };
  };
}
