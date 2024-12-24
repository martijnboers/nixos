{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.sync;
in {
  options.hosts.sync = {
    enable = mkEnableOption "Firefox sync";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."sync.thuis".extraConfig = ''
      tls {
        issuer internal { ca hadouken }
      }
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://localhost:${toString config.services.firefox-syncserver.settings.port}
      }
      respond 403
    '';

    age.secrets.sync.file = ../../../secrets/sync.age;

    services = {
      firefox-syncserver = {
        enable = true;
        secrets = config.age.secrets.sync.path;
        package = pkgs.stable.syncstorage-rs;

        settings = {
          host = "0.0.0.0";
          port = 8579;
        };
        logLevel = "info";
        singleNode = {
          enable = true;
          hostname = "sync.thuis";
          url = "https://sync.thuis";
        };
      };
      mysql.package = pkgs.mariadb;
    };
  };
}
