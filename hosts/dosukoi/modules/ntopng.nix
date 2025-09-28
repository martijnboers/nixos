{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.ntopng;
in
{
  options.hosts.ntopng = {
    enable = mkEnableOption "Network monitoring";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."leases.thuis".extraConfig = ''
      import headscale
      handle @internal {
        reverse_proxy http://localhost:${toString config.services.ntopng.httpPort}
      }
      respond 403
    '';

    age.secrets.geoip.file = ../../../secrets/geoip.age;

    services = {
      geoipupdate = {
        enable = true;
        settings = {
          EditionIDs = [
            "GeoLite2-Country"
            "GeoLite2-City"
            "GeoLite2-ASN"
          ];
          AccountID = 1232114;
          LicenseKey = config.age.secrets.geoip.path;
        };
      };
      ntopng = {
        enable = true;
        httpPort = 3023;
        interfaces = [
          "wan"
          "lan"
          "wifi"
          "opt1"
          "tailscale0"
          "wg0"
        ];
      };
      # borgbackup.jobs.default.paths = [ "/var/lib/" ];
    };
  };
}
