{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.headscale;
  hadoukenRecords = [
    "vaultwarden"
    "atuin"
    "tools"
    "monitoring"
    "immich"
    "ollama"
    "sync"
    "archive"
    "binarycache"
    "search"
    "chat"
    "cal"
    "webdav"
    "detection"
  ];
  shoryukenRecords = [
    "notifications"
    "uptime"
    "prowlarr"
  ];
  tenshinRecords = [
    "dns"
    "hass"
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
      borgbackup.jobs.default.paths = [config.services.headscale.settings.database.sqlite.path];
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
          policy.path = pkgs.writeText "acl.json" ''
            {
              "hosts": {
                "router": "100.64.0.7",
                "pikvm": "100.64.0.4",
                "shoryuken": "100.64.0.1",
                "tenshin": "100.64.0.11",
                "hadouken": "100.64.0.2",
                "glassdoor": "100.64.0.8",
                "mbp": "100.64.0.10",
                "pixel": "100.64.0.6"
              },
              "acls": [
                  {
                    "action": "accept",
                    "src": ["router"],
                    "dst": [
                      "shoryuken:8025",
                      "tenshin:53"
                    ]
                  },
                  {
                    "action": "accept",
                    "src": ["shoryuken"],
                    "dst": [
                      "tenshin:53,443",
                      "pikvm:443"
                    ]
                  },
                  {
                    "action": "accept",
                    "src": ["hadouken"],
                    "dst": [
                      "tenshin:*",
                      "shoryuken:*",
                      "glassdoor:9100"
                    ]
                  },
                  {
                    "action": "accept",
                    "src": ["glassdoor"],
                    "dst": [
                      "tenshin:*",
                      "shoryuken:*",
                      "hadouken:*",
                      "router:4433",
                      "pikvm:80,443"
                    ]
                  },
                  {
                    "action": "accept",
                    "src": ["pixel"],
                    "dst": [
                      "tenshin:53,80,443",
                      "shoryuken:80,443",
                      "hadouken:80,443",
                      "router:4433",
                      "pikvm:80,443"
                    ]
                  },
                  {
                    "action": "accept",
                    "src": ["mbp"],
                    "dst": [
                      "tenshin:53,80,443",
                      "hadouken:80,443",
                      "pikvm:80,443"
                    ]
                  }
                ]
              }
          '';
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
            tenshinIp = "100.64.0.11";
            makeRecord = name: ip: {
              name = "${name}.thuis";
              type = "A";
              value = ip;
            };
          in {
            magic_dns = true;
            base_domain = "machine.thuis";
            nameservers.global = [tenshinIp];
            extra_records =
              (map (name: makeRecord name hadoukenIp) hadoukenRecords)
              ++ (map (name: makeRecord name shoryukenIp) shoryukenRecords)
              ++ (map (name: makeRecord name tenshinIp) tenshinRecords);
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
