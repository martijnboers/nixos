{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.syncthing;
in {
  options.hosts.syncthing = {
    enable = mkEnableOption "Synchronize files with devices";
    ipaddress = mkOption {
      type = types.str;
      default = "undefined";
      description = "Tailscale IP address of the computer";
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      guiAddress = "${cfg.ipaddress}:8384";
      openDefaultPorts = true;
      user = "martijn";
      dataDir = "/home/martijn/Sync"; # Default folder for new synced folders
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings = {
        devices = {
          "glassdoor" = {
            id = "L77BOY3-HVS7OGS-6ABZ3T6-RDUSIB4-GZHNSCW-B5DVI3V-74JW4B6-T7B6PAS";
            autoAcceptFolders = true;
            allowedNetwork = "100.64.0.0/10";
            addresses = [
              "tcp://100.64.0.4:22000"
            ];
          };
          "phone" = {
            id = "4ROZWW2-EAWAQ3S-NQDS7HL-HHJU2PT-UJNRCRE-ZO5VKPN-CECNL6D-LEEYLQP";
            autoAcceptFolders = true;
            allowedNetwork = "100.64.0.0/10";
            addresses = [
              "tcp://100.64.0.3:22000"
            ];
          };
          "lapdance" = {
            id = "DZMLQOR-CGFZN2K-RATVUCL-PTTDLPO-FYEVRCB-3W2OARE-YFXJIGD-KGRZNAO";
            autoAcceptFolders = true;
            allowedNetwork = "100.64.0.0/10";
            addresses = [
              "tcp://100.64.0.1:22000"
            ];
          };
          "hadouken" = {
            id = "KSZBEEG-YXNPG3M-XFSTOSE-NPGHHUR-QNNNYKO-YTQYDOE-MRRLJVF-VR2YCQU";
            autoAcceptFolders = true;
            allowedNetwork = "100.64.0.0/10";
            addresses = [
              "tcp://100.64.0.2:22000"
            ];
          };
          "suydersee" = {
            id = "56U3WOL-6CFE2LR-LDANZED-TSRYHR6-7HSL2IP-YS7TJFG-PMCXBQR-PABK7AM";
            autoAcceptFolders = true;
            allowedNetwork = "100.64.0.0/10";
            addresses = [
              "tcp://100.64.0.5:22000"
            ];
          };
        };
        folders = {
          "Obsidian" = {
            path = "~/Sync/Obsidian";
            devices = ["glassdoor" "phone" "lapdance" "hadouken"];
          };
          "Music" = {
            path = "/mnt/garage/Music";
            devices = ["hadouken" "suydersee"];
          };
        };
        options = {
          urAccepted = -1;
          localAnnounceEnabled = false;
          globalAnnounceEnabled = false;
          reconnectionIntervalM = 5;
          listenAddresses = [
            "tcp4://${cfg.ipaddress}:22000"
          ];
        };
      };
    };
  };
}
