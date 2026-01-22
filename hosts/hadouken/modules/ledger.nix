{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.ledger;
  # The port the container will listen on internally on the host
  internalPort = 3000;
in
{
  options.hosts.ledger = {
    enable = mkEnableOption "Finances";
  };

  config = mkIf cfg.enable {

    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true; # Needed for certain docker-compose features
    };
    virtualisation.oci-containers.backend = "podman";

    # Firewall configuration for Podman interfaces
    # This is to allow container name DNS resolution for Podman networks.
    networking.firewall.interfaces = let
      matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
    in {
      "${matchAll}".allowedUDPPorts = [ 53 ];
    };

    # Secret file for the containers.
    # It should contain SECRET_KEY_BASE, OIDC_CLIENT_SECRET, and POSTGRES_PASSWORD
    age.secrets = {
      sure = {
        file = ../../../secrets/sure.age;
        owner = "root"; 
      };
      postgres-sure = {
        file = ../../../secrets/postgres-sure.age;
        owner = config.services.postgresql.user;
        group = config.services.postgresql.group;
      };
    };

    # Reverse proxy to the sure-web container, now accessible on the host's port
    services.caddy.virtualHosts."geld.thuis".extraConfig = ''
      import headscale
      handle @internal {
        reverse_proxy http://127.0.0.1:${toString internalPort}
      }
      respond 403
    '';

    # Native NixOS service for PostgreSQL
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "sure" ];
      ensureUsers = [{
        name = "sure";
      }];
      # Allow TCP-based password authentication from localhost, which the container will use.
      authentication = ''
        host all sure 127.0.0.1/32 md5
      '';
    };

    # Native NixOS service for Redis
    services.redis.servers.sure = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;
    };

    # OCI container definitions for Sure web and worker
    virtualisation.oci-containers = {
      containers = {
        sure-web = {
          image = "ghcr.io/we-promise/sure:stable"; # Using 'stable' tag for consistency
          # Use host networking to easily connect to postgres/redis on localhost
          extraOptions = [ "--network=host" ];
          # Use the NixOS-managed named volume
          volumes = [ "sure_app-storage:/rails/storage" ];
          environment = {
            # Database connection details (for native NixOS service)
            DB_HOST = "127.0.0.1";
            DB_PORT = "5432";
            POSTGRES_USER = "sure";
            POSTGRES_DB = "sure";

            # Redis connection details (for native NixOS service)
            REDIS_URL = "redis://127.0.0.1:6379/1"; # Matching example compose.yml's Redis DB index

            # Rails configuration
            APP_DOMAIN = "geld.thuis";
            RAILS_ASSUME_SSL = "true";
            RAILS_FORCE_SSL = "false"; # From compose.example.yml
            SELF_HOSTED = "true";

            # OIDC configuration (from previous discussions)
            OIDC_ISSUER = "https://auth.boers";
            OIDC_CLIENT_ID = "euroos";
            OIDC_REDIRECT_URI = "https://geld.thuis/auth/openid_connect/callback";
            ONBOARDING_STATE = "open";

            # Misc
            EXCHANGE_RATE_PROVIDER = "yahoo_finance";
            SECURITIES_PROVIDER = "yahoo_finance";
            OPENAI_ACCESS_TOKEN = ""; # From compose.example.yml, assuming empty for now
          };
        };

        sure-worker = {
          image = "ghcr.io/we-promise/sure:stable"; # Using 'stable' tag for consistency
          cmd = [ "bundle" "exec" "sidekiq" ]; # Corrected from `entrypoint` to `cmd`
          extraOptions = [ "--network=host" ];
          volumes = [ "sure_app-storage:/rails/storage" ];
          environment = config.virtualisation.oci-containers.containers.sure-web.environment; # Inherit from web
        };
      };
    };

    # Systemd service overrides for containers
    # Ensures containers start after native services and load secrets.
    systemd.services = {
      "oci-container-sure-web.service" = {
        after = [ "postgresql.service" "redis-sure.service" ];
        serviceConfig.EnvironmentFile = config.age.secrets.sure.path;
        serviceConfig.Restart = "always"; # From compose2nix restart policy
      };
      "oci-container-sure-worker.service" = {
        after = [ "postgresql.service" "redis-sure.service" ];
        serviceConfig.EnvironmentFile = config.age.secrets.sure.path;
        serviceConfig.Restart = "always"; # From compose2nix restart policy
      };
    };
  };
}
