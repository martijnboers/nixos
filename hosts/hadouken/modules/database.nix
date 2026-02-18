{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.database;
in
{
  options.hosts.database = {
    enable = mkEnableOption "PostgreSQL";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "pgadmin.thuis".extraConfig = ''
        import headscale
        import mtls

        handle @internal {
          reverse_proxy http://localhost:${toString config.services.pgadmin.port}
        }
        respond 403
      '';
      "minio.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://${toString config.services.minio.listenAddress}
        }
        respond 403
      '';
      "minio-admin.thuis".extraConfig = ''
        import headscale
        import mtls

        handle @internal {
          reverse_proxy http://${toString config.services.minio.consoleAddress}
        }
        respond 403
      '';
    };

    services.postgresql = {
      enable = true;
      enableTCPIP = true;
      authentication = lib.mkOverride 10 ''
        #type database  DBuser  range		        auth-method
        local all       all                     trust
        host  all       all     100.64.0.0/10   trust
      '';
    };

    age.secrets = {
      pgadmin.file = ../../../secrets/pgadmin.age;
      minio.file = ../../../secrets/minio.age;
    };

    services.minio = {
      enable = true;
      region = "thuis";
      listenAddress = "0.0.0.0:5554";
      consoleAddress = "localhost:9901";
      rootCredentialsFile = config.age.secrets.minio.path;
      dataDir = [ "/mnt/zwembad/games/minio" ];
    };

    services.pgadmin = {
      enable = true;
      initialEmail = "m@b.com";
      initialPasswordFile = config.age.secrets.pgadmin.path;
    };

    services.postgresqlBackup = {
      enable = true;
      databases = [
        "mastodon"
        "atuin"
        "immich"
        "pgrok"
        "fluidcalendar"
      ];
    };

    services.borgbackup.jobs.default.paths = [
      config.services.postgresqlBackup.location
      config.services.minio.configDir
    ];
  };
}
