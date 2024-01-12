{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.headscale;
in {
  options.hosts.headscale = {
    enable = mkEnableOption "VPN server";
  };

  config = mkIf cfg.enable {
    services = {
      caddy.virtualHosts."headscale.plebian.nl".extraConfig = ''
        reverse_proxy http://localhost:${toString config.services.headscale.port}
      '';
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 7070;
        settings = {
          server_url = "https://headscale.plebian.nl";
          logtail.enabled = false;
          dns_config = {
            nameservers = ["100.64.0.2"];
            base_domain = "plebian.nl";
            extra_records = [
              {
                name = "vaultwarden.thuis.plebian.nl";
                type = "A";
                value = "100.64.0.2";
              }
            ];
          };
          ip_prefixes = ["100.64.0.0/10" "fd7a:115c:a1e0::/48"];
        };
      };
    };
    # Is this necessary?
    environment.systemPackages = [config.services.headscale.package];
  };
}
