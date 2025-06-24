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
    networking.firewall.allowedTCPPorts = [
      80
      443
      8448 # matrix
    ];

    environment.systemPackages = [ pkgs.nss ];

    services.caddy = {
      enable = true;
      globalConfig = ''
        acme_ca https://acme.thuis/acme/intermediate/directory
        acme_ca_root ${../../../secrets/keys/PLEBS4DIAMOND.crt}
        servers {
            trusted_proxies static 100.64.0.0/10
        }
      '';
      extraConfig = ''
        (headscale) {
          @internal remote_ip 100.64.0.0/10
        }
      '';
    };
  };
}
