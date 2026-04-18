{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.hosts.stalwart;

  # Node configuration
  shoryukenIp = config.global.tailscale_hosts.shoryuken;
  rekkakenIp = config.global.tailscale_hosts.rekkaken;
  stalwartPkg = pkgs.stalwart-custom;

  # Email domains we handle
  emailDomains = [
    "plebian.nl"
    "boers.email"
  ];
in
{
  options.hosts.stalwart = {
    enable = lib.mkEnableOption "Stalwart Mail Server with clustering";

    nodeId = lib.mkOption {
      type = lib.types.int;
      description = ''
        Unique node ID for this Stalwart instance in the cluster.
        Must be unique across all nodes. Shoryuken=1, Rekkaken=2.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to open firewall ports for Stalwart services.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        25 # SMTP
        465 # SMTPS
        587 # SMTP Submission
        993 # IMAPS
      ];
    };

    # Agenix secrets - use the stalwart-mail user that NixOS module creates
    age.secrets = {
      stalwart-postgresql = {
        file = "${inputs.secrets}/stalwart-postgresql.age";
        owner = "stalwart-mail";
        group = "stalwart-mail";
      };
      stalwart-s3-secret = {
        file = "${inputs.secrets}/stalwart-s3-secret.age";
        owner = "stalwart-mail";
        group = "stalwart-mail";
      };
    };

    # Stalwart service - use NixOS module with overrides
    services.stalwart = {
      enable = true;
      package = stalwartPkg;

      settings = {
        # Cluster configuration
        cluster = {
          node-id = cfg.nodeId;
          coordinator = "p2p";
        };

        # Stores configuration - use mkForce to override defaults completely
        store = lib.mkForce {
          # Peer-to-peer coordination using Zenoh
          p2p = {
            type = "zenoh";
            config = ''
              {
                mode: "peer",
                scouting: {
                  multicast: {
                    enabled: false
                  },
                  gossip: {
                    enabled: false
                  }
                },
                connect: {
                  endpoints: [
                    "tcp/${if cfg.nodeId == 1 then rekkakenIp else shoryukenIp}:17447"
                  ]
                },
                listen: {
                  endpoints: [
                    "tcp/0.0.0.0:17447"
                  ]
                }
              }
            '';
          };

          # PostgreSQL storage backend
          postgresql = {
            type = "postgresql";
            host = "hadouken.machine.thuis";
            port = 5432;
            database = "stalwart";
            user = "stalwart";
            password = config.age.secrets.stalwart-postgresql.path;
            timeout = "15s";
            pool.max-connections = 10;
          };

          # Garage S3 blob storage
          s3 = {
            type = "s3";
            bucket = "email";
            region = "us-east-1";
            endpoint = "https://garage.thuis";
            access-key = "GKee41184bbe37aed170c62a32";
            secret-key = config.age.secrets.stalwart-s3-secret.path;
            timeout = "30s";
          };
        };

        storage = {
          data = "postgresql";
          fts = "postgresql";
          lookup = "postgresql";
          blob = "postgresql";
          directory = "internal";
        };

        # Directory configuration (internal for now)
        directory.internal = {
          type = "internal";
          store = "postgresql";
        };

        # Server listeners - properly nested
        server = {
          listener = {
            smtp = {
              bind = [ "[::]:25" ];
              protocol = "smtp";
            };
            smtp-submission = {
              bind = [ "[::]:587" ];
              protocol = "smtp";
            };
            smtps = {
              bind = [ "[::]:465" ];
              protocol = "smtp";
              tls.implicit = true;
            };
            imaps = {
              bind = [ "[::]:993" ];
              protocol = "imap";
              tls.implicit = true;
            };
            http = {
              bind = [ "127.0.0.1:8629" ];
              protocol = "http";
            };
          };

          # Auto-ban configuration - aggressive security (properly nested)
          auto-ban = {
            auth = {
              rate = "10/1h"; # Ban after 10 failed auth attempts per hour
            };
            abuse = {
              rate = "20/1d"; # Ban after 20 abuse attempts per day
            };
            scan = {
              rate = "10/1h"; # Ban aggressive port scanners
              paths = [
                "*.php*"
                "*.cgi*"
                "*/wp-*"
                "*xmlrpc*"
                "*joomla*"
                "*wordpress*"
                "*drupal*"
              ];
            };
          };
        };

        # Certificate configuration
        certificate = {
          acme = {
            acme = "letsencrypt";
          };
        };

        # ACME (Let's Encrypt) configuration
        acme.letsencrypt = {
          directory = "https://acme-v02.api.letsencrypt.org/directory";
          challenge = "tls-alpn-01";
          contact = [ "postmaster@boers.email" ];
          domains = emailDomains ++ (map (d: "mail.${d}") emailDomains);
        };

        # Queue configuration - properly nested with tls settings
        queue = {
          retry = [
            "2m"
            "5m"
            "10m"
            "15m"
            "30m"
            "1h"
            "2h"
          ];
          expire = "3d";

          # TLS settings for outbound mail (properly nested)
          tls.default = {
            starttls = "require";
            allow-invalid-certs = false;
            dane = "optional"; # Use DANE when available
            mta-sts = "optional"; # Use MTA-STS when available
          };
        };

        # Resolver configuration
        resolver = {
          type = "system";
          public-suffix = [ "file://${pkgs.publicsuffix-list}/share/publicsuffix/public_suffix_list.dat" ];
        };

        # Tracing configuration
        tracer.journal = {
          type = "journal";
          level = "info";
          enable = true;
        };

        # Use pkgs because not built with overrideAttrs
        spam-filter.resource = "file://${pkgs.stalwart-spam-filter}/spam-filter.toml";

        webadmin = {
          resource = "file://${pkgs.stalwart-webadmin}/webadmin.zip";
          path = "/var/cache/stalwart-mail";
        };

        # Only first time; openssl passwd -6 'something'
        # ---------------------------------
        authentication.fallback-admin = {
          user = "admin";
          secret = "$6$3Amnk6ObFGqfd/dA$Fu2DVSdt6onbt8Tjo.AFFn0qq9APvBoM/164n/wjTIfw.P1oNqQWaibLD5Z1rTAKPy3c3F6HmEncxJXo/9WyE1";
        };
        # ---------------------------------
      };

    };

    # Caddy reverse proxy for web admin (Tailscale internal only)
    services.caddy.virtualHosts = {
      "mail-admin.thuis" = {
        extraConfig = ''
          import headscale
          # import mtls

          handle @internal {
            reverse_proxy http://127.0.0.1:8629
          }
          respond 403
        '';
      };
    };

    # Ensure Stalwart can connect to Tailscale network
    systemd.services.stalwart = {
      after = [ "tailscaled.service" ];
      requires = [ "tailscaled.service" ];
    };
  };
}
