{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.caddy;
  plebian = builtins.fetchGit {
    url = "https://github.com/martijnboers/plebian.nl.git";
    rev = "b07146995f7b227ef7692402374268f0457003aa";
  };
  resume = builtins.fetchGit {
    url = "git@github.com:martijnboers/resume.git";
    rev = "b7d75859c8ce0c2867c95c5924623e397a2600f9";
  };
in
{
  options.hosts.caddy = {
    enable = mkEnableOption "Ghetto CloudFlare proxies";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
      8448 # matrix
    ];

    services.caddy = {
      enable = true;
      package = pkgs.callPackage ../../../pkgs/xcaddy.nix {
        plugins = [
          "github.com/darkweak/souin/plugins/caddy"
          "github.com/caddy-dns/cloudflare"
        ];
      };
      globalConfig = ''
        metrics {
            per_host
        }

        servers {
            trusted_proxies static 100.64.0.0/10
            enable_full_duplex
        }

        pki {
            ca shoryuken {
        	name shoryuken
        	# openssl genrsa -out root.key 4096
        	# openssl req -x509 -new -nodes -key root.key -sha256 -days 3650 -out root.crt -config /etc/pki-root.cnf
        	root {
        	    cert ${../../../secrets/keys/shoryuken.crt}
        	    key  ${config.age.secrets.shoryuken-pki.path}
        	}
            }
        }

        # https://docs.souin.io/docs/middlewares/caddy/
        cache {
            ttl 100s
            stale 3h
            default_cache_control public, s-maxage=100
        }
      '';
      extraConfig = ''
        matrix.plebian.nl, matrix.plebian.nl:8448 {
            reverse_proxy /_matrix/* http://${config.hidden.tailscale_hosts.hadouken}:5553
        }
      '';
      virtualHosts =
        let
          makeProxy = public: target: {
            extraConfig = ''
              reverse_proxy https://${target} {
                  header_up Host ${target}
                  header_up X-Forwarded-Host ${public}
                  header_up X-Forwarded-Proto https
                  header_up X-Real-IP {remote_host}
                }
            '';
          };
        in
        {
          "plebian.nl" = {
            serverAliases = [ "boers.email" ];
            extraConfig = ''
              cache {
                  ttl 1h
              }
              root * ${plebian}/
              encode zstd gzip
              file_server

              route /.well-known/matrix/server {
                  header Access-Control-Allow-Origin "*"
                  header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
                  header Access-Control-Allow-Headers "X-Requested-With, Content-Type, Authorization"
                  respond `{
                      "m.server": "matrix.plebian.nl:443"
                  }`
              }

              route /.well-known/matrix/client {
                  header Access-Control-Allow-Origin "*"
                  header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
                  header Access-Control-Allow-Headers "X-Requested-With, Content-Type, Authorization"
                  respond `{
                      "m.homeserver": {
                          "base_url": "https://matrix.plebian.nl"
                      }
                  }`
              }
            ''; # makes it possible to do @martijn:plebian.nl
          };
          "resume.plebian.nl" = {
            serverAliases = [ "resume.boers.email" ];
            extraConfig = ''
              cache { ttl 1h }
              root * ${resume}/
              encode zstd gzip
              file_server
            '';
          };
          "storage.plebian.nl" = {
            extraConfig = ''
                            reverse_proxy hadouken.machine.thuis:5554 
              	      header Access-Control-Allow-Origin *
            '';
          };
          "noisesfrom.space" = {
            extraConfig = ''
              handle /api/v1/streaming/* {
                  reverse_proxy hadouken.machine.thuis:5552
              }

              handle_path /system/* {
                  reverse_proxy https://mastodon.thuis { header_up Host {upstream_hostport} } 
              }

              route * {
                  file_server * {
                    root ${pkgs.mastodon}/public
                    pass_thru
                  }
                  reverse_proxy hadouken.machine.thuis:5551
              }

              handle_errors {
                  root * ${pkgs.mastodon}/public
                  rewrite 500.html
                  file_server
              }

              encode gzip

              header /* {
                  Strict-Transport-Security "max-age=31536000;"
              }

              header /emoji/* Cache-Control "public, max-age=31536000, immutable"
              header /packs/* Cache-Control "public, max-age=31536000, immutable"
              header /system/accounts/avatars/* Cache-Control "public, max-age=31536000, immutable"
              header /system/media_attachments/files/* Cache-Control "public, max-age=31536000, immutable"
            '';
          };
          "p.plebian.nl" = makeProxy "p.plebian.nl" "microbin.thuis";
          "kevinandreihana.com" = makeProxy "kevinandreihana.com" "wedding.thuis";
          "sea.plebian.nl" = makeProxy "sea.plebian.nl" "seaf.thuis";
        };
    };
    systemd.services.caddy = {
      serviceConfig = {
        # Required to use ports < 1024
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        EnvironmentFile = config.age.secrets.caddy.path;
        TimeoutStartSec = "5m";
      };
    };

    age.secrets = {
      caddy.file = ../../../secrets/caddy.age;
      shoryuken-pki = {
        file = ../../../secrets/shoryuken-pki.age;
        owner = "caddy";
      };
    };
  };
}
