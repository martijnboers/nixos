{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.ledger;
  port = 3033;
in
{
  options.hosts.ledger = {
    enable = mkEnableOption "Finances";
  };

  config = mkIf cfg.enable {

    age.secrets.sure = {
      file = ../../../secrets/sure.age;
      owner = "sure";
      group = "sure";
    };

    services.caddy.virtualHosts."geld.thuis".extraConfig = ''
      import headscale
      handle @internal {
        reverse_proxy http://127.0.0.1:${toString port}
      }
      respond 403
    '';

    users.groups.sure = { };
    users.users.sure = {
      group = "sure";
      isSystemUser = true;
      description = "Sure Rails Application";
    };

    systemd.services.sure = {
      description = "Sure Rails App";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "postgresql.service"
      ];

      environment = {
        RAILS_ENV = "production";
        RAILS_LOG_TO_STDOUT = "true";
        RAILS_SERVE_STATIC_FILES = "true";
        PORT = toString port;
        BOOTSNAP_CACHE_DIR = "/var/lib/sure/bootsnap";
        DATABASE_URL = "postgresql://sure@localhost/sure?host=/run/postgresql";
        HOME = "/var/lib/sure";

        # OIDC
        OIDC_ISSUER = "https://auth.boers";
        OIDC_CLIENT_ID = "your-oidc-client-id";
        OIDC_REDIRECT_URI = "https://yourdomain.com/auth/openid_connect/callback";

        # Enables local Email/Password login (disables forced OIDC)
        ONBOARDING_STATE = "open";
        APP_DOMAIN = "geld.thuis";

        # Use free providers for stock/currency data (no API key needed)
        EXCHANGE_RATE_PROVIDER = "yahoo_finance";
        SECURITIES_PROVIDER = "yahoo_finance";
      };

      serviceConfig = {
        User = "sure";
        Group = "sure";
        StateDirectory = "sure";
        WorkingDirectory = "${pkgs.sure}";
        EnvironmentFile = config.age.secrets.sure.path;
        ExecStartPre = "${pkgs.sure}/bin/sure-server db:prepare";
        ExecStart = "${pkgs.sure}/bin/sure-server server";
        Restart = "always";
        RestartSec = "10s";
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "sure" ];
      ensureUsers = [
        {
          name = "sure";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
