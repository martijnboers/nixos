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
