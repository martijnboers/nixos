{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.headscale;
  shoryukenIp = "100.64.0.1";
  hadoukenIp = "100.64.0.2";
in {
  options.hosts.headscale = {
    enable = mkEnableOption "VPN server";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [config.services.headscale.package];

    services = {
      caddy.virtualHosts."headscale.cloud.plebian.nl".extraConfig = ''
        reverse_proxy http://localhost:${toString config.services.headscale.port}
      '';
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 7070;
        settings = {
          server_url = "https://headscale.cloud.plebian.nl";
          oidc = {
            issuer = "https://auth.cloud.plebian.nl/realms/master";
            client_id = "headscale";
            client_secret_path = config.age.secrets.headscale.path;
            allowed_users = ["martijn@plebian.nl"];
          };
          acl_policy_path = config.age.secrets.acl.path;
          logtail.enabled = false;
          database = {
            type = "sqlite3";
            sqlite = {
              path = "/var/lib/headscale/db.sqlite";
            };
          };
          dns_config = {
            base_domain = "machine.thuis";
            override_local_dns = true;
            nameservers = [hadoukenIp];
            extra_records = [
              {
                name = "vaultwarden.thuis";
                type = "A";
                value = hadoukenIp;
              }
              {
                name = "atuin.thuis";
                type = "A";
                value = hadoukenIp;
              }
              {
                name = "dns.thuis";
                type = "A";
                value = hadoukenIp;
              }
              {
                name = "hass.thuis";
                type = "A";
                value = hadoukenIp;
              }
              {
                name = "tools.thuis";
                type = "A";
                value = hadoukenIp;
              }
              {
                name = "monitoring.thuis";
                type = "A";
                value = hadoukenIp;
              }
              {
                name = "immich.thuis";
                type = "A";
                value = hadoukenIp;
              }
              {
                name = "ollama.thuis";
                type = "A";
                value = hadoukenIp;
              }
              {
                name = "notifications.thuis";
                type = "A";
                value = shoryukenIp;
              }
              {
                name = "uptime.thuis";
                type = "A";
                value = shoryukenIp;
              }
              {
                name = "kvm.thuis";
                type = "A";
                value = "100.64.0.4";
              }
              {
                name = "router.thuis";
                type = "A";
                value = "100.64.0.6";
              }
              {
                name = "kvm.plebian";
                type = "A";
                value = "100.64.0.4";
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
      acl = {
        file = ../../../secrets/acl.age;
        owner = config.services.headscale.user;
      };
    };
  };
}
