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
      description = "IP address of the computer";
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      guiAddress = "${cfg.ipaddress}:8384";
      user = "martijn";
      dataDir = "/home/martijn/Sync"; # Default folder for new synced folders
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings = {
        devices = {
          "glassdoor" = {id = "L77BOY3-HVS7OGS-6ABZ3T6-RDUSIB4-GZHNSCW-B5DVI3V-74JW4B6-T7B6PAS";};
          "phone" = {id = "BLHVSN7-DCVI4WC-D6YUCS6-XAOZX4L-VUZGQU3-MMJWI2T-MFUL4D7-E7A4KAI";};
        };
        folders = {
          "Obsidian" = {
            path = "~/Sync/Obsidian";
            devices = ["glassdoor" "phone"];
          };
        };
      };
    };

    # 22000 TCP and/or UDP for sync traffic
    # 21027/UDP for discovery
    networking.firewall.allowedTCPPorts = [8384 22000];
    networking.firewall.allowedUDPPorts = [22000 21027];
  };
}
