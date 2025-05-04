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
    "binarycache"
    "cal"
    "chat"
    "detection"
    "immich"
    "microbin"
    "minio"
    "monitoring"
    "ollama"
    "pgadmin"
    "seaf"
    "search"
    "sync"
    "tools"
    "vaultwarden"
    "webdav"
    "wedding"
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
in
{
  options.hosts.headscale = {
    enable = mkEnableOption "VPN server";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ config.services.headscale.package ];

    services = {
      caddy.virtualHosts."headscale.plebian.nl" = {
        serverAliases = [ "headscale.donder.cloud" ];
        extraConfig = ''
          reverse_proxy http://localhost:${toString config.services.headscale.port}
        '';
      };
      borgbackup.jobs.default.paths = [ config.services.headscale.settings.database.sqlite.path ];
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 7070;
        settings = {
          server_url = "https://headscale.plebian.nl";
          derp = {
            # urls = []; # only use custom derp server
            paths = [
              (pkgs.writeText "derpmap.yaml" (
                lib.generators.toYAML { } {
                  regions = {
                    "900" = {
                      regionid = 900;
                      regioncode = "thuis";
                      regionname = "In the void";
                      nodes = [
                        {
                          name = "900";
                          regionid = 900;
                          hostname = config.hidden.wan_domain;
                          stunport = 0;
                          stunonly = false;
                          derpport = 0;
                        }
                      ];
                    };
                  };
                }
              ))
            ];
          };
          oidc = {
            issuer = "https://auth.plebian.nl/realms/master";
            client_id = "headscale";
            client_secret_path = config.age.secrets.headscale.path;
            allowed_users = [ "martijn@plebian.nl" ];
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
                pivkm = config.hidden.tailscale_hosts.pivkm;
              };

              groups = {
                "group:trusted" = [ "martijn" ];
              };

              acls = [
                {
                  action = "accept";
                  src = [ "group:trusted" ];
                  dst = [ "tenshin:53,80,443" ]; # everyone access to dns
                }
                {
                  action = "accept";
                  src = [
                    "mbp"
                    "pixel"
                    "nurma"
                  ];
                  dst = [ "autogroup:internet:*" ]; # allow exit-nodes
                }
                {
                  action = "accept";
                  src = [ "shoryuken" ];
                  dst = [
                    "hadouken:80,443,5551,5552,5553,5554"
                  ];
                }
                {
                  action = "accept";
                  src = [ "tenshin" ];
                  dst = [
                    "shoryuken:80,443,2230" # notifications
                  ];
                }
                {
                  action = "accept";
                  src = [ "mpb" ];
                  dst = [
                    "hadouken:80,443"
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
                    "nurma:9100"
                  ];
                }
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
                    "router:4433"
                    "pikvm:443"
                  ];
                }
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
              nameservers.global = [ config.hidden.tailscale_hosts.tenshin ];
              extra_records =
                (map (name: makeRecord name config.hidden.tailscale_hosts.hadouken) hadoukenRecords)
                ++ (map (name: makeRecord name config.hidden.tailscale_hosts.shoryuken) shoryukenRecords)
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
