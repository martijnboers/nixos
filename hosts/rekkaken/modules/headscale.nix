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
    "detection"
    "immich"
    "kal"
    "microbin"
    "minio"
    "monitoring"
    "ollama"
    "pgadmin"
    "seaf"
    "sync"
    "vaultwarden"
    "webdav"
    "wedding"
    "llm"
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
    "dns"
    "hass"
    "search"
    "tools"
    "chat"
  ];
  tatsumakiRecords = [
    "mempool"
  ];

  headplanePort = 8089;
  format = pkgs.formats.yaml { };

  # A workaround generate a valid Headscale config accepted by Headplane when `config_strict == true`.
  settings = lib.recursiveUpdate config.services.headscale.settings {
    acme_email = "/dev/null";
    tls_cert_path = "/dev/null";
    tls_key_path = "/dev/null";
    policy.path = "/dev/null";
    oidc.client_secret_path = "/dev/null";
  };
  headscaleConfig = format.generate "headscale.yml" settings;
in
{
  options.hosts.headscale = {
    enable = mkEnableOption "VPN server";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ config.services.headscale.package ];

    systemd.services.headplane = {
      environment = {
        HEADPLANE_LOAD_ENV_OVERRIDES = "true";
      };
      serviceConfig.EnvironmentFile = config.age.secrets.headplane.path;
    };

    services = {
      caddy.virtualHosts = {
        "headscale.plebian.nl".extraConfig = ''
          reverse_proxy http://localhost:${toString config.services.headscale.port}
        '';
        "vpn.thuis".extraConfig = ''
          import headscale
          handle @internal {
            reverse_proxy http://localhost:${toString headplanePort}
          }
          respond 403
        '';
        "vpn-callback.plebian.nl".extraConfig = ''
          @oidc_paths path /oidc/callback* /signin-oidc* /oauth2/callback* /login/oauth2/code/*

          handle @oidc_paths {
            reverse_proxy http://localhost:${toString headplanePort}
          }
	  respond 403
        '';
      };

      borgbackup.jobs.default.paths = [ config.services.headscale.settings.database.sqlite.path ];

      headplane = {
        enable = true;
        agent.enable = false;
        settings = {
          server = {
            host = "127.0.0.1";
            port = headplanePort;
            cookie_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; # overwritten by env
            cookie_secure = true;
          };
          headscale = {
            url = "https://headscale.plebian.nl";
            config_path = "${headscaleConfig}";
            config_strict = false;
          };
          integration.proc.enabled = true;
          oidc = {
            issuer = "https://auth.plebian.nl/realms/master";
            client_id = "headplane";
            headscale_api_key = "overwritten";
            disable_api_key_login = true;
            redirect_uri = "https://vpn-callback.plebian.nl/oidc/callback";
            token_endpoint_auth_method = "client_secret_basic";
          };
        };
      };

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
                          hostname = config.hidden.hadouken.wan_domain;
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
                pikvm = config.hidden.tailscale_hosts.pikvm;
                rekkaken = config.hidden.tailscale_hosts.rekkaken;
              };

              groups = {
                "group:trusted" = [ "martijn@" ];
              };

              acls = [
                {
                  action = "accept";
                  src = [ "group:trusted" ];
                  dst = [
                    "tenshin:53,80,443" # everyone access to dns
                    "rekkaken:80,443,8025,2230" # everyone can send notifications + internal email
                    "shoryuken:80,443" # everyone can request acme certs
                    "hadouken:80,443" # everyone can access hadouken web-services
                  ];
                }
                {
                  action = "accept";
                  src = [
                    "mbp"
                    "pixel"
                    "nurma"
                  ];
                  dst = [
                    "autogroup:internet:*" # allow exit-nodes
                    "hadouken:22"
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
                    "pikvm:443"
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
              nameservers.global = [ config.hidden.tailscale_hosts.tenshin ];
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
      headplane = {
        file = ../../../secrets/headplane.age;
        owner = config.services.headscale.user;
      };
      headscale = {
        file = ../../../secrets/headscale.age;
        owner = config.services.headscale.user;
      };
    };
  };
}
