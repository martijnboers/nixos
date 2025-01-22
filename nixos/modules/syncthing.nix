{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.syncthing;
in {
  options.hosts.syncthing = {
    enable = mkEnableOption "Syncthing syncing seed";
    name = mkOption {
      type = types.str;
      description = "Name of the device";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [22000];
      allowedUDPPorts = [22000 21027]; # 22 is for traffic, 21 for discovery
    };

    services = {
      syncthing = {
        enable = true;
        dataDir = "/mnt/zwembad/app/syncthing";
        configDir = "/mnt/zwembad/app/syncthing/.config/syncthing";
        overrideDevices = true;
        overrideFolders = true;
        guiAddress = "0.0.0.0:8384";
        settings = {
          options = {
            urAccepted = 1;
            relaysEnabled = false;
            localAnnounceEnabled = false;
            crashReportingEnabled = false;
          };
          devices = {
            "seed" = {id = "C3CPMI7-DKDUEYC-ALWM3HN-X37N7S7-DNECILF-UUAX4TY-6F7QLEZ-Q7HSTQV";};
            "hadouken" = {id = "AVHC54J-6NTZ6SS-Y5UUYLZ-LE4QIZ5-AGZAUON-2VWB4XW-2O7W3HV-6MIGTQK";};
          };
          folders = {
            "hot" = {
              path = "/mnt/zwembad/hot";
              devices = ["seed" "hadouken"];
            };
            "music" = {
              path = "/mnt/zwembad/music";
              devices = ["seed" "hadouken"];
            };
          };
        };
      };
    };
  };
}
