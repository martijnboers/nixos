{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.plex;
in {
  options.hosts.plex = {
    enable = mkEnableOption "plex";
  };

  config = mkIf cfg.enable {
    services.plex = {
      enable = true;
      openFirewall = true;
      dataDir = "/mnt/zwembad/app/plex";
    };
  };
}
