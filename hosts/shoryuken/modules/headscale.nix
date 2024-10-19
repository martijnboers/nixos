{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.headscale;
  hadoukenRecords = [
    "vaultwarden"
    "atuin"
    "dns"
    "hass"
    "tools"
    "monitoring"
    "immich"
    "ollama"
    "sync"
    "archive"
    "binarycache"
  ];
  shoryukenRecords = [
    "notifications"
    "uptime"
  ];
in {
  options.hosts.headscale = {
    enable = mkEnableOption "VPN server";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [config.services.headscale.package];

    services = {
      caddy.virtualHosts."headscale.donder.cloud".extraConfig = ''
        reverse_proxy http://localhost:${toString config.services.headscale.port}
      '';
      borgbackup.jobs.default.paths = [config.services.headscale.settings.db_path];
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 7070;
        settings = {
          server_url = "https://headscale.donder.cloud";
          oidc = {
            issuer = "https://auth.donder.cloud/realms/master";
            client_id = "headscale";
            client_secret_path = config.age.secrets.headscale.path;
            allowed_users = ["martijn@plebian.nl"];
          };
          policy.path = config.age.secrets.acl.path;
          logtail.enabled = false;
          database = {
            type = "sqlite3";
            sqlite = {
              path = "/var/lib/headscale/db.sqlite";
            };
          };
          dns = let
            shoryukenIp = "100.64.0.1";
            hadoukenIp = "100.64.0.2";
            makeRecord = name: ip: {
              name = "${name}.thuis";
              type = "A";
              value = ip;
            };
          in {
            magic_dns = true;
            base_domain = "machine.thuis";
            nameservers.global = [hadoukenIp];
            extra_records =
              (map (name: makeRecord name hadoukenIp) hadoukenRecords)
              ++ (map (name: makeRecord name shoryukenIp) shoryukenRecords);
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
