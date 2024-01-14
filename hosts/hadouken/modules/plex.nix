{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.plex;
in {
  options.hosts.plex = {
    enable = mkEnableOption "Plex.tv enabled";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [32400];
    networking.firewall.allowedUDPPorts = [32400];

    services.plex = {
      enable = true;
      openFirewall = true;
    };
  };
}
