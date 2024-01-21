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
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings = {
        devices = {
          "glassdoor" = {
            id = "D3FA3AV-TMGC6HM-ULQSUKR-NBX4UCX-FQ53V7Y-HJ73FHY-KGYUE2Y-FVXTPQJ";
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
            id = "T235TJH-GWV7O3T-KQ57U47-W6MH5GC-JXCCIO2-37ZBP2C-HWDGL7A-LDM43Q7"; # TODO: change
            autoAcceptFolders = true;
            allowedNetwork = "100.64.0.0/10";
            addresses = [
              "tcp://100.64.0.2:22000"
            ];
          };
          "suydersee" = {
            id = "MNA6KRH-GULVLRX-ONZVPOP-V4ZXYPJ-Q6RGBVC-UQQ4FPZ-P6IGWSJ-RLHGGQ6";
            autoAcceptFolders = true;
            allowedNetwork = "100.64.0.0/10";
            addresses = [
              "tcp://100.64.0.5:22000"
            ];
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
