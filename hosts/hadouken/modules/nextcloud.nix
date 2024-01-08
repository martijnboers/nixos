{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.nextcloud;
in {
  options.hosts.nextcloud = {
    enable = mkEnableOption "Next cloud server";
  };

  config = mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      database.createLocally = true;
      hostName = "next.plebian.nl";
      https = true;
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.age.secrets.nextcloud.path;
      };
      enableImagemagick = true;
      caching = flip genAttrs (_: true) [
        "apcu"
        "redis"
      ];
    };
  };
}
