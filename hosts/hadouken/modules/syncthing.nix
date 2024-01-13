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
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."syncthing.thuis.plebian.nl".extraConfig = ''
      reverse_proxy http://100.64.0.2:8384
    '';

    services.syncthing = {
      enable = true;
      guiAddress = "100.64.0.2:8384";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      settings = {
        devices = {
          "glassdoor" = {id = "OGMFMVP-NAUEZKG-DXPWGED-V4OE2NY-FEUCU75-RWRN7UP-ZOK6J3H-CIKA2QY";};
          "phone" = {id = "BLHVSN7-DCVI4WC-D6YUCS6-XAOZX4L-VUZGQU3-MMJWI2T-MFUL4D7-E7A4KAI";};
        };
      };
    };

    # 22000 TCP and/or UDP for sync traffic
    # 21027/UDP for discovery
    networking.firewall.allowedTCPPorts = [22000];
    networking.firewall.allowedUDPPorts = [22000 21027];
  };
}
