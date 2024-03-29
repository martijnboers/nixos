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
          oidc = {
            issuer = "https://auth.plebian.nl/realms/master";
            client_id = "headscale";
            client_secret_path = config.age.secrets.headscale.path;
            allowed_users = ["martijn@plebian.nl"];
          };
          logtail.enabled = false;
          dns_config = {
            base_domain = "plebian.nl";
            override_local_dns = true;
            nameservers = [
              "100.64.0.2"
            ];
            extra_records = [
              {
                name = "vaultwarden.thuis.plebian.nl";
                type = "A";
                value = "100.64.0.2";
              }
              {
                name = "atuin.thuis.plebian.nl";
                type = "A";
                value = "100.64.0.2";
              }
              {
                name = "dns.thuis.plebian.nl";
                type = "A";
                value = "100.64.0.2";
              }
              {
                name = "hass.thuis.plebian.nl";
                type = "A";
                value = "100.64.0.2";
              }
            ];
          };
          prefixes = {
            v4 = "100.64.0.0/10";
            v6 = "fd7a:115c:a1e0::/48";
          };
        };
      };
    };

    age.secrets = {
      headscale = {
        file = ../../../secrets/headscale.age;
        owner = config.services.headscale.user;
      };
    };
  };
}
