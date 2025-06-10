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
        	root {
        	    cert ${../../../secrets/keys/shoryuken.crt}
        	    key  ${config.age.secrets.shoryuken-pki.path}
        	}
            }
        }
      '';
      extraConfig = ''
        (headscale) {
          @internal remote_ip 100.64.0.0/10
          tls {
            issuer internal { ca shoryuken }
          }
        }
        matrix.plebian.nl, matrix.plebian.nl:8448 {
            reverse_proxy /_matrix/* http://${config.hidden.tailscale_hosts.hadouken}:5553
        }
      '';
      virtualHosts =
        let
          makeProxy = public: target: {
            ${public} = {
              extraConfig = ''
                reverse_proxy https://${target} {
                    header_up Host ${target}
                    header_up X-Forwarded-Host ${public}
                    header_up X-Forwarded-Proto https
                    header_up X-Real-IP {remote_host}
                  }
              '';
            };
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
            extraConfig = # caddy
              ''
                # Encode responses with Gzip
                encode gzip

                # Set security-related headers
                header {
                    # Enable HSTS
                    Strict-Transport-Security "max-age=31536000;"
                    # Prevent clickjacking
                    X-Frame-Options "DENY"
                    # Prevent MIME-sniffing
                    X-Content-Type-Options "nosniff"
                    # Enable XSS protection
                    X-XSS-Protection "1; mode=block"
                    # Referrer Policy
                    Referrer-Policy "strict-origin-when-cross-origin"
                }

                header /emoji/* Cache-Control "public, max-age=31536000, immutable"
                header /packs/* Cache-Control "public, max-age=31536000, immutable"
                header /assets/* Cache-Control "public, max-age=31536000, immutable" 
                header /system/accounts/avatars/* Cache-Control "public, max-age=31536000, immutable"
                header /system/media_attachments/files/* Cache-Control "public, max-age=31536000, immutable"

                @static_assets {
                    path /assets/* /packs/* /emoji/* /sounds/*
                    path /favicon.ico /robots.txt /manifest.json /sw.js
                    path /apple-touch-icon*.png /mstile-*.png /browserconfig.xml
                    path /oops.html /500.html /404.html /422.html /403.html # Error pages
                }
                handle @static_assets {
                    root * ${pkgs.mastodon}/public
                    file_server
                }

                handle /api/v1/streaming/* {
                    reverse_proxy hadouken.machine.thuis:5552
                }

                handle_path /system/* {
                    reverse_proxy https://mastodon.thuis {
                        header_up Host {upstream_hostport}
                    }
                }

                handle {
                    reverse_proxy hadouken.machine.thuis:5551 {
                    }
                }
                handle_errors {
                    root * ${pkgs.mastodon}/public
                    rewrite * /500.html 
                    file_server
                }
              '';
          };
        }
        // makeProxy "p.plebian.nl" "microbin.thuis"
        // makeProxy "sea.plebian.nl" "seaf.thuis";
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
