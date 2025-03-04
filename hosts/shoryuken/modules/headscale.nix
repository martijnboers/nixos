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
  hosts = {
    shoryuken = "100.64.0.1";
    hadouken = "100.64.0.2";
    tatsumaki = "100.64.0.3";
    tenshin = "100.64.0.11";
  };
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
          policy.path = pkgs.writeText "acl.json" (builtins.toJSON
            {
              hosts = {
                shoryuken = hosts.shoryuken;
                tenshin = hosts.tenshin;
                hadouken = hosts.hadouken;
		tatsumaki = hosts.tatsumaki;
                nurma = "100.64.0.8";
                pikvm = "100.64.0.4";
                mbp = "100.64.0.10";
                pixel = "100.64.0.6";
              };

              groups = {
                "group:trusted" = ["martijn"];
              };

              acls = [
                {
                  action = "accept";
                  src = ["group:trusted"];
                  dst = ["tenshin:53,80,443"]; # everyone access to dns
                }
                {
                  action = "accept";
                  src = ["mbp" "pixel" "nurma"];
                  dst = ["autogroup:internet:*" "hadouken:443"]; # allow exit-nodes + webservices
                }
                {
                  action = "accept";
                  src = ["shoryuken" "mpb"];
                  dst = [
                    "hadouken:80,443"
                    "pikvm:443"
                  ];
                }
                {
                  action = "accept";
                  src = ["hadouken"];
                  dst = [
                    "tenshin:*"
                    "shoryuken:*"
		    "tatsumaki:*"
                    "nurma:9100"
                  ];
                }
                {
                  action = "accept";
                  src = ["nurma" "pixel"];
                  dst = [
                    "tenshin:*"
                    "shoryuken:*"
                    "hadouken:*"
		    "tatsumaki:*"
                    "pikvm:80,443"
                  ];
                }
              ];
            });
          logtail.enabled = false;
          database = {
            type = "sqlite3";
            sqlite = {
              path = "/var/lib/headscale/db.sqlite";
            };
          };
          dns = let
            makeRecord = name: ip: {
              name = "${name}.thuis";
              type = "A";
              value = ip;
            };
          in {
            magic_dns = true;
            base_domain = "machine.thuis";
            nameservers.global = [hosts.tenshin];
            extra_records =
              (map (name: makeRecord name hosts.hadouken) hadoukenRecords)
              ++ (map (name: makeRecord name hosts.shoryuken) shoryukenRecords)
              ++ (map (name: makeRecord name hosts.tenshin) tenshinRecords);
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
