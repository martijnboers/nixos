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
    networking.firewall.allowedTCPPorts = [
      80
      443
      8448 # matrix
    ];

    services.caddy = {
      enable = true;
      globalConfig = ''
        servers {
            trusted_proxies static 100.64.0.0/10
        }
        pki {
            ca rekkaken {
        	name rekkaken
        	root {
        	    cert ${../../../secrets/keys/rekkaken.crt}
        	    key  ${config.age.secrets.rekkaken-pki.path}
        	}
            }
        }
      '';
      extraConfig = ''
        (headscale) {
          @internal remote_ip 100.64.0.0/10
          tls {
            issuer internal { ca rekkaken }
          }
        }
      '';
    };

    age.secrets = {
      rekkaken-pki = {
        file = ../../../secrets/rekkaken-pki.age;
        owner = "caddy";
      };
    };
  };
}
