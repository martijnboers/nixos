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
          ca tenshin {
            name     tenshin
            # openssl genrsa -out root.key 4096
            # openssl req -x509 -new -nodes -key root.key -sha256 -days 3650 -out root.crt -config /etc/pki-root.cnf
            root {
              cert   ${../../../nixos/keys/tenshin.crt}
              key    ${config.age.secrets.tenshin-pki.path}
            }
          }
        }
      '';
    };

    age.secrets = {
      tenshin-pki = {
        file = ../../../secrets/tenshin-pki.age;
        owner = "caddy";
      };
    };
  };
}
