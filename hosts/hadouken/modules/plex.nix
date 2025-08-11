{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.plex;
in
{
  options.hosts.plex = {
    enable = mkEnableOption "plex";
  };

  config = mkIf cfg.enable {
    services.plex = {
      enable = true;
      openFirewall = true;
      package = pkgs.customplex;
      dataDir = "/mnt/zwembad/app/plex";
    };
  };
}
