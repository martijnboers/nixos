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
      '';
      extraConfig = ''
        (headscale) {
          @internal remote_ip 100.64.0.0/10
	  tls {
	    ca https://acme.thuis/acme/plebs4gold/directory
	  }
        }
      '';
    };
  };
}
