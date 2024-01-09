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
    services.nginx.enable = false;
    services.phpfpm.pools.nextcloud.settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
    };
    # Needed to read /var/lib/nextcloud
    users.groups.nextcloud.members = ["nextcloud" config.services.caddy.user];

    age.secrets.nextcloud = {
      file = ../../../secrets/nextcloud.age;
      owner = "nextcloud";
    };

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
