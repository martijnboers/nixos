{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.endlessh;
in
{
  options.hosts.endlessh = {
    enable = mkEnableOption "Come join my server";
  };

  config = mkIf cfg.enable {
    age.secrets.geoip.file = ../../../secrets/geoip.age;

    services = {
      geoipupdate = {
        enable = true;
        settings = {
          EditionIDs = [
            "GeoLite2-City"
          ];
          AccountID = 1003091;
          LicenseKey = config.age.secrets.geoip.path;
        };
      };
      endlessh-go = {
        enable = true;
        port = 23;
        prometheus = {
          enable = true;
        };
        extraOptions = [
          "-geoip_supplier=max-mind-db"
          "-max_mind_db=${toString config.services.geoipupdate.settings.DatabaseDirectory}/GeoLite2-City.mmdb"
        ];
        openFirewall = true;
      };
    };
    systemd.services.endlessh-go = {
      after = [ "network.target" ];
      serviceConfig.BindReadOnlyPaths = [ config.services.geoipupdate.settings.DatabaseDirectory ];
    };
  };
}
