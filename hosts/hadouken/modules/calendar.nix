{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.calendar;
  radicaleListenAddress = "0.0.0.0:5232";
in
{
  options.hosts.calendar = {
    enable = mkEnableOption "WebDAV + CardDAV + web calendar";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "cal.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://${radicaleListenAddress}
        }
        respond 403
      '';
    };

    services.borgbackup.jobs.default.paths = [ "/var/lib/radicale/collections/" ];

    age.secrets.radicale = {
      file = ../../../secrets/radicale.age;
      owner = "radicale";
      group = "radicale";
    };

    services.radicale = {
      enable = true;
      settings.server.hosts = [ radicaleListenAddress ];
      settings.auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale.path;
        htpasswd_encryption = "autodetect";
      };
    };
  };
}
