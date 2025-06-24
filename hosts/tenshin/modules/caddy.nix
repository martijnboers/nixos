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
      extraConfig = ''
        (headscale) {
          @internal remote_ip 100.64.0.0/10
          tls {
            issuer internal { ca tenshin }
          }
        }
      '';
      globalConfig = ''
        pki {
          ca tenshin {
            name     tenshin
            intermediate {
              cert   ${../../../secrets/keys/tenshin.crt}
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
