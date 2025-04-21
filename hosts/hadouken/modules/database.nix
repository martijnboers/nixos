{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.database;
in {
  options.hosts.database = {
    enable = mkEnableOption "PostgreSQL";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."pgadmin.thuis".extraConfig = ''
      tls {
        issuer internal { ca hadouken }
      }
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://localhost:${toString config.services.pgadmin.port}
      }
      respond 403
    '';

    services.postgresql = {
      enable = true;
      enableTCPIP = true;
      authentication = lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
        host  all       all     100.64.0.0/10   trust
      '';
    };
   
    age.secrets.pgadmin.file = ../../../secrets/pgadmin.age;

    services.pgadmin = {
      enable = true;
      initialEmail = "m@b.com";
      initialPasswordFile = config.age.secrets.pgadmin.path;
    };

    services.postgresqlBackup = {
      enable = true;
      databases = ["mastodon" "atuin" "immich" "pgrok"];
    };

    services.borgbackup.jobs.default.paths = [config.services.postgresqlBackup.location];
  };
}
