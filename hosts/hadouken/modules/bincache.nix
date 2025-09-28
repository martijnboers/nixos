{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.bincache;
in
{
  options.hosts.bincache = {
    enable = mkEnableOption "Binary cache with attic";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."bincache.thuis".extraConfig = ''
      import headscale
      handle @internal {
       reverse_proxy http://${toString config.services.atticd.settings.listen}
      }
      respond 403
    '';
    age.secrets.binarycache = {
      file = ../../../secrets/binarycache.age;
    };

    services.postgresql = {
      ensureDatabases = [ "bincache" ];
      ensureUsers = [
        {
          name = "bincache";
          ensureDBOwnership = true;
        }
      ];
    };

    services.atticd = {
      enable = true;
      environmentFile = config.age.secrets.binarycache.path;

      settings = {
        listen = "127.0.0.1:8322";
        api-endpoint = "https://bincache.thuis/";
        database.url = "postgresql:///bincache?host=/run/postgresql&user=bincache";
        storage = {
          type = "s3";
          region = "thuis";
          bucket = "bincache";
          endpoint = "https://minio.thuis";
        };
        garbage-collection.default-retention-period = "6 months";
        chunking = {
          nar-size-threshold = 64 * 1024; # 64 KiB
          min-size = 16 * 1024; # 16 KiB
          avg-size = 64 * 1024; # 64 KiB
          max-size = 256 * 1024; # 256 KiB
        };
      };
    };

    services.shiori = {
      enable = true;
      port = 4354;
      environmentFile = config.age.secrets.shiori.path;
    };
  };
}
