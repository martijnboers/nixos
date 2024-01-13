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
      reverse_proxy http://localhost:8384
    '';

    services.syncthing = {
      enable = true;
    };

    # 22000 TCP and/or UDP for sync traffic
    # 21027/UDP for discovery
    networking.firewall.allowedTCPPorts = [22000];
    networking.firewall.allowedUDPPorts = [22000 21027];
  };
}
