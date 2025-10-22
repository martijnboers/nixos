{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.syncthing;
in
{
  options.hosts.syncthing = {
    enable = mkEnableOption "Syncthing syncing seed";
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 22000 ];
    };

    services.caddy.virtualHosts."syncthing.thuis".extraConfig = ''
      import headscale
      handle @internal {
        reverse_proxy http://${config.services.syncthing.guiAddress}
      }
      respond 403
    '';

    systemd.services.syncthing = {
      serviceConfig.AmbientCapabilities = "cap_chown"; # allow taking parent permissions
    };

    services.syncthing = {
      enable = true;
      dataDir = "/mnt/zwembad/app/syncthing";
      configDir = "/mnt/zwembad/app/syncthing/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      guiAddress = "127.0.0.1:8384";
      settings = {
        options = {
          urAccepted = 1;
          relaysEnabled = false;
          localAnnounceEnabled = false;
          crashReportingEnabled = false;
        };
        gui.insecureSkipHostcheck = true; # reverse proxy
        devices = {
          "seed" = {
            id = "C3CPMI7-DKDUEYC-ALWM3HN-X37N7S7-DNECILF-UUAX4TY-6F7QLEZ-Q7HSTQV";
          };
          "hadouken" = {
            id = "AVHC54J-6NTZ6SS-Y5UUYLZ-LE4QIZ5-AGZAUON-2VWB4XW-2O7W3HV-6MIGTQK";
          };
        };
        folders = {
          "hot" = {
            path = "/mnt/zwembad/hot/Downloads";
            copyOwnershipFromParent = true;
            devices = [
              "seed"
              "hadouken"
            ];
          };
          "music" = {
            path = "/mnt/zwembad/music";
            copyOwnershipFromParent = true;
            devices = [
              "seed"
              "hadouken"
            ];
          };
        };
      };
    };
  };
}
