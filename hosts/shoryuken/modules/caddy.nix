{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.caddy;
  info = builtins.fetchGit {
    url = "https://github.com/martijnboers/boers.email.git";
    rev = "113945f8d61a244f403a3a85085d86e7b77ba724";
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
          "boers.email" = {
            serverAliases = [ "plebian.nl" ];
            extraConfig = ''
              cache {
                  ttl 1h
              }
              root * ${info}/
              encode zstd gzip
              file_server

              header /.well-known/matrix/* Content-Type application/json
              header /.well-known/matrix/* Access-Control-Allow-Origin *
              respond /.well-known/matrix/server `{"m.server": "matrix.boers.email:443"}`
              respond /.well-known/matrix/client `{
                "m.homeserver": {"base_url":"https://matrix.boers.email"},
                "m.identity_server":{"base_url":"https://identity.boers.email"}
              }`
            ''; # makes it possible to do @martijn:boers.email
          };
          "matrix.boers.email" = {
            extraConfig = ''
              reverse_proxy /_matrix/* http://${config.hidden.tailscale_hosts.hadouken}:5553
              reverse_proxy /_synapse/client/* http://${config.hidden.tailscale_hosts.hadouken}:5553
            '';
          };
          "resume.boers.email" = {
            extraConfig = ''
              cache { ttl 1h }
              root * ${resume}/
              encode zstd gzip
              file_server
            '';
          };
          "storage.boers.email" = {
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
                    root * ${pkgs.glitch-soc}/public
                    file_server
                }

                handle /api/v1/streaming/* {
                    reverse_proxy hadouken.machine.thuis:5552
                }

                handle {
                    reverse_proxy hadouken.machine.thuis:5551
                }
                handle_errors {
                    root * ${pkgs.glitch-soc}/public
                    rewrite * /500.html 
                    file_server
                }
              '';
          };
        }
        // makeProxy "p.plebian.nl" "microbin.thuis"
        // makeProxy "sea.boers.email" "seaf.thuis";
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
    };
  };
}
