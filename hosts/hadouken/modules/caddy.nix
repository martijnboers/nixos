{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.caddy;
  plebian = builtins.fetchGit {
    url = "https://github.com/martijnboers/plebian.nl.git";
    rev = "b07146995f7b227ef7692402374268f0457003aa";
  };
  resume = builtins.fetchGit {
    url = "git@github.com:martijnboers/resume.git";
    rev = "b7d75859c8ce0c2867c95c5924623e397a2600f9";
  };
in {
  options.hosts.caddy = {
    enable = mkEnableOption "Caddy base";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.caddy = {
      enable = true;
      package = pkgs.callPackage ../../../pkgs/xcaddy.nix {
        plugins = [
          "github.com/caddy-dns/cloudflare"
          "github.com/corazawaf/coraza-caddy/v2"
          "github.com/darkweak/souin/plugins/caddy"
          "github.com/mholt/caddy-webdav"
        ];
      };

      globalConfig = ''
        servers {
            metrics
        }

        pki {
          ca hadouken {
            name     hadouken
            # openssl genrsa -out root.key 4096
            # openssl req -x509 -new -nodes -key root.key -sha256 -days 3650 -out root.crt -config /etc/pki-root.cnf
            root {
              cert   ${../../../secrets/keys/hadouken.crt}
              key    ${config.age.secrets.hadouken-pki.path}
            }
          }
        }

        # https://docs.souin.io/docs/middlewares/caddy/
        cache {
            ttl 100s
            stale 3h
            default_cache_control public, s-maxage=100
        }
        order coraza_waf first
        order webdav before file_server
      '';
      virtualHosts = {
        "plebian.nl" = {
          serverAliases = ["boers.email"];
          extraConfig = ''
            cache { ttl 1h }
            root * ${plebian}/
            encode zstd gzip
            file_server
          '';
        };
        "resume.plebian.nl" = {
          serverAliases = ["resume.boers.email"];
          extraConfig = ''
            cache { ttl 1h }
            root * ${resume}/
            encode zstd gzip
            file_server
          '';
        };
        "webdav.thuis:80".extraConfig = ''
            @internal {
              remote_ip 100.64.0.0/10
            }
            handle @internal {
              route {
                rewrite /android /android/
                rewrite /notes /notes/
                webdav /android/* {
                  root /mnt/zwembad/app/android
                  prefix /android
                }
                webdav /notes/* {
                  root /mnt/zwembad/app/notes
                  prefix /notes
                }
                file_server
              }
            }
          respond 403
        '';
      };
    };

    age.secrets = {
      caddy.file = ../../../secrets/caddy.age;
      hadouken-pki = {
        file = ../../../secrets/hadouken-pki.age;
        owner = "caddy";
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
  };
}
