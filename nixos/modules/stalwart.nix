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

  stalwartPkg = pkgs.stalwart.overrideAttrs (oldAttrs: {
    buildFeatures = [
      "postgres" # PostgreSQL database backend
      "s3" # Garage S3 blob storage
      "zenoh" # P2P clustering coordination
    ];

    # Disable LTO for faster build
    cargoLtoMode = null;
    doCheck = false;
  });
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
      stalwart-admin = {
        file = "${inputs.secrets}/stalwart-admin.age";
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
            config = "{mode: peer, scouting: {multicast: {enabled: false}, gossip: {enabled: true}}, connect: {endpoints: [tcp/${
              if cfg.nodeId == 1 then rekkakenIp else shoryukenIp
            }:17447]}, listen: {endpoints: [tcp/0.0.0.0:17447]}}";
          };

          # PostgreSQL storage backend
          postgresql = {
            type = "postgresql";
            host = "hadouken.machine.thuis";
            port = 5432;
            database = "stalwart";
            user = "stalwart";
            password = "%{file:/run/credentials/stalwart.service/postgresql_password}%";
            timeout = "15s";
            pool.max-connections = 10;
          };

          # Garage S3 blob storage
          s3 = {
            type = "s3";
            bucket = "mail";
            region = "thuis";
            endpoint = "https://garage.thuis";
            access-key = "GKe41184bbe37aed170c62a32";
            secret-key = "%{file:/run/credentials/stalwart.service/s3_secret_key}%";
            timeout = "30s";
            key-prefix = "stalwart/";
          };
        };

        # Storage configuration - use our custom stores
        storage = {
          data = "postgresql";
          fts = "postgresql";
          lookup = "postgresql";
          blob = "s3";
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
              bind = [ "127.0.0.1:8080" ];
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
          contact = [ "postmaster@%{DEFAULT_DOMAIN}%" ];
          domains = [
            "%{DEFAULT_DOMAIN}%"
            "mail.%{DEFAULT_DOMAIN}%"
          ];
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

        # Spam filter
        spam-filter.resource = "file://${stalwartPkg.spam-filter}/spam-filter.toml";

        # Authentication fallback admin (for initial setup)
        authentication.fallback-admin = {
          user = "admin";
          secret = "%{file:/run/credentials/stalwart.service/admin_password}%";
        };

        # Session configuration - domains we accept mail for
        session.rcpt.relay = [
          "plebian.nl"
          "boers.email"
        ];
      };

      credentials = {
        postgresql_password = config.age.secrets.stalwart-postgresql.path;
        s3_secret_key = config.age.secrets.stalwart-s3-secret.path;
        admin_password = config.age.secrets.stalwart-admin.path;
      };
    };

    # Caddy reverse proxy for web admin (Tailscale internal only)
    services.caddy.virtualHosts = {
      "mail-admin.thuis" = {
        extraConfig = ''
          import headscale
          import mtls

          handle @internal {
            reverse_proxy http://127.0.0.1:8080
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
