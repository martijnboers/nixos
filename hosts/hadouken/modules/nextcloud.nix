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

    services.caddy.virtualHosts."${config.services.nextcloud.hostName}".extraConfig = ''
      coraza_waf {
          load_owasp_crs
          directives `
              Include @coraza.conf-recommended
              SecRuleEngine On
          `
      }
      root * ${config.services.nextcloud.package}
       root /store-apps/* ${config.services.nextcloud.home}
       root /nix-apps/* ${config.services.nextcloud.home}
       encode zstd gzip

       php_fastcgi unix//${config.services.phpfpm.pools.nextcloud.socket}
       file_server

       header {
         Strict-Transport-Security max-age=31536000;
       }

       redir /.well-known/carddav /remote.php/dav 301
       redir /.well-known/caldav /remote.php/dav 301
    '';

    services.borgbackup.jobs.default.paths = [config.services.nextcloud.home];

    services.nextcloud = {
      enable = true;
      database.createLocally = true;
      hostName = "next.plebian.nl";
      package = pkgs.nextcloud29;
      # home = "/mnt/zwembad/app/nextcloud";
      https = true;
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.age.secrets.nextcloud.path;
      };
      enableImagemagick = true;
      configureRedis = true;
    };
  };
}
