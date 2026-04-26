{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.hosts.umami;
in
{
  options.hosts.umami = {
    enable = mkEnableOption "Self hosted analytics";
  };

  config = mkIf cfg.enable {
    age.secrets.geoip.file = "${inputs.secrets}/geoip.age";
    age.secrets.umami.file = "${inputs.secrets}/umami.age";
    age.secrets.umami-db.file = "${inputs.secrets}/umami-db.age";

    services.umami = {
      enable = true;
      createPostgresqlDatabase = false;
      settings = {
        HOSTNAME = "127.0.0.1";
        PORT = 3000;
        APP_SECRET_FILE = config.age.secrets.umami.path;
        DATABASE_URL_FILE = config.age.secrets.umami-db.path;
      };
    };
  };
}
