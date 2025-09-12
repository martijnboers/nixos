{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.headscale;
  hadoukenRecords = [
    "archive"
    "atuin"
    "cal"
    "detection"
    "dns"
    "immich"
    "llm"
    "microbin"
    "minio"
    "monitoring"
    "ollama"
    "paper"
    "pgadmin"
    "pingvin"
    "vaultwarden"
    "webdav"
  ];
  shoryukenRecords = [
    "acme"
  ];
  rekkakenRecords = [
    "notifications"
    "vpn"
    "uptime"
  ];
  tenshinRecords = [
    "dns-fallback"
    "hass"
    "search"
    "tools"
    "chat"
  ];
  tatsumakiRecords = [
    "mempool"
  ];
in
{
  options.hosts.headscale = {
    enable = mkEnableOption "VPN server";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ config.services.headscale.package ];

    services = {
      caddy.virtualHosts = {
        "headscale.boers.email" = {
          extraConfig = ''
            reverse_proxy http://localhost:${toString config.services.headscale.port}
          '';
        };
        "derp-map.boers.email" = {
          extraConfig = ''
            header /regions Content-Type application/json
            respond /regions `${
              builtins.toJSON {
                Regions = {
                  "900" = {
                    RegionID = 900;
                    RegionCode = "lel";
                    RegionName = "The Void";
                    Nodes = [
                      {
                        Name = "1";
                        RegionID = 900;
                        HostName = "derp1.boers.email";
                      }
                      {
                        Name = "2";
                        RegionID = 900;
                        HostName = "derp2.boers.email";
                      }
                    ];
                  };
                };
              }
            }`
          '';
        };
      };

      borgbackup.jobs.default.paths = [ config.services.headscale.settings.database.sqlite.path ];

      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 7092;
        settings = {
          server_url = "https://headscale.boers.email";
          derp.urls = [
            "https://derp-map.boers.email/regions"
            "https://controlplane.tailscale.com/derpmap/default"
          ];
          oidc = {
            issuer = "https://auth.boers.email";
            client_id = "d88ca9d8-ee44-48d0-a993-b83a0830e937";
            client_secret_path = config.age.secrets.headscale.path;
            allowed_users = [
              "headscale-server@boers.email"
              "headscale-user@boers.email"
            ];
          };
          policy.path = pkgs.writeText "acl.json" (
            builtins.toJSON {
              randomizeClientPort = true; # direct connection pfsense
              hosts = {
                shoryuken = config.hidden.tailscale_hosts.shoryuken;
                tenshin = config.hidden.tailscale_hosts.tenshin;
                hadouken = config.hidden.tailscale_hosts.hadouken;
                tatsumaki = config.hidden.tailscale_hosts.tatsumaki;
                nurma = config.hidden.tailscale_hosts.nurma;
                mbp = config.hidden.tailscale_hosts.mbp;
                pixel = config.hidden.tailscale_hosts.pixel;
                router = config.hidden.tailscale_hosts.router;
                pikvm = config.hidden.tailscale_hosts.pikvm;
                rekkaken = config.hidden.tailscale_hosts.rekkaken;
              };

              acls = [
                {
                  action = "accept";
                  src = [ "*" ];
                  dst = [
                    "hadouken:53,80,443" # everyone can access hadouken web-services, dns
                    "tenshin:53,80,443" # everyone access to dns fallback
                    "rekkaken:80,443,8025,2230,49837" # everyone can send notifications + internal email + crowdsec lapi
                    "shoryuken:80,443" # everyone can request acme certs
                  ];
                }
                {
                  action = "accept";
                  src = [ "shoryuken" ];
                  dst = [
                    "hadouken:5551,5552,5553,5554" # reverse proxy ports
                  ];
                }
                {
                  action = "accept";
                  src = [ "tatsumaki" ];
                  dst = [
                    "hadouken:2049" # nfs
                  ];
                }
                {
                  action = "accept";
                  src = [ "hadouken" ];
                  dst = [
                    "tenshin:*"
                    "shoryuken:*"
                    "tatsumaki:*"
                    "rekkaken:*"
                    "nurma:9100"
                  ];
                } # hadouken semi-god
                {
                  action = "accept";
                  src = [
                    "nurma"
                    "pixel"
                  ];
                  dst = [
                    "tenshin:*"
                    "shoryuken:*"
                    "hadouken:*"
                    "tatsumaki:*"
                    "rekkaken:*"
                    "router:4433"
                    "pikvm:80,443"
                  ];
                } # nurma full-god
              ];
            }
          );
          logtail.enabled = false;
          database = {
            type = "sqlite3";
            sqlite = {
              path = "/var/lib/headscale/db.sqlite";
            };
          };
          dns =
            let
              makeRecord = name: ip: {
                name = "${name}.thuis";
                type = "A";
                value = ip;
              };
            in
            {
              magic_dns = true;
              base_domain = "machine.thuis";
              nameservers.global = [
                config.hidden.tailscale_hosts.hadouken
                config.hidden.tailscale_hosts.tenshin
              ];
              extra_records =
                (map (name: makeRecord name config.hidden.tailscale_hosts.hadouken) hadoukenRecords)
                ++ (map (name: makeRecord name config.hidden.tailscale_hosts.shoryuken) shoryukenRecords)
                ++ (map (name: makeRecord name config.hidden.tailscale_hosts.tatsumaki) tatsumakiRecords)
                ++ (map (name: makeRecord name config.hidden.tailscale_hosts.rekkaken) rekkakenRecords)
                ++ (map (name: makeRecord name config.hidden.tailscale_hosts.tenshin) tenshinRecords);
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
