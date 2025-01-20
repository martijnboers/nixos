{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.caddy;
  plebianRepo = builtins.fetchGit {
    url = "https://github.com/martijnboers/plebian.nl.git";
    rev = "b07146995f7b227ef7692402374268f0457003aa";
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
              cert   ${../../../nixos/keys/hadouken.crt}
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
            root * ${plebianRepo}/
            encode zstd gzip
            file_server
          '';
        };
        "tmp-dont-hurt-me.plebian.nl".extraConfig = ''
          tls internal
          basicauth {
             babydonthurtme $2a$14$/BY0vrLPhDunnWXdJUe.3u6LBE6ECoHoSghIX3iQRiSSST858XeYehashed_password_base64
          }
          route {
            rewrite /seedvault /seedvault/
            webdav /seedvault/* {
              root /mnt/zwembad/app/seedvault-tmp
              prefix /seedvault
            }
          }
        '';
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
        #   "resume.plebian.nl" = {
        #     serverAliases = ["resume.boers.email"];
        #     extraConfig = ''
        #       cache { ttl 48h }
        #       root * ${pkgs.resume-hugo}/
        #       encode zstd gzip
        #       file_server
        #     '';
        #   };
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
