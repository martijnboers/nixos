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
    plex = {
      enable = true;
      openFirewall = true;
    };
  };
}
