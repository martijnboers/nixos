{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.radicale;
  listenAddress = "0.0.0.0:5232";
in {
  options.hosts.radicale = {
    enable = mkEnableOption "WebDAV + CardDAV";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."cal.thuis".extraConfig = ''
        tls {
          issuer internal { ca hadouken }
        }
        @internal {
          remote_ip 100.64.0.0/10
        }
        handle @internal {
          reverse_proxy http://${listenAddress}
        }
      respond 403
    '';
    services.borgbackup.jobs.default.paths = ["/var/lib/radicale/collections/"];
    age.secrets.radicale = {
      file = ../../../secrets/radicale.age;
      owner = "radicale";
      group = "radicale";
    };
    services.radicale = {
      enable = true;
      settings.server.hosts = [listenAddress];
      settings.auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale.path;
        htpasswd_encryption = "autodetect";
      };
    };
  };
}
