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
    ];

    services.caddy = {
      enable = true;
      globalConfig = ''
        servers {
            trusted_proxies static 100.64.0.0/10
        }
        metrics {
          per_host
        }
      '';
      virtualHosts = {
        "ip.boers.email" = {
          extraConfig = ''
            header Content-Type "text/plain; charset=utf-8"
            templates
            respond "{{.RemoteIP}}"
          '';
        };
      };
      extraConfig = ''
        (headscale) {
          @internal remote_ip 100.64.0.0/10
          tls {
            ca https://acme.thuis:4443/acme/gitgetgot/directory
          }
        }
        (mtls) {
          tls {
            client_auth {
              mode require_and_verify
              trust_pool file {
        	pem_file ${../../../secrets/keys/plebs4platinum.crt}
              }
            }
          }
        }
      '';
    };
  };
}
