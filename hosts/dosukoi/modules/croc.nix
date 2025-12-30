{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.croc;
in
{
  options.hosts.croc = {
    enable = mkEnableOption "Croc relay";
  };

  config = mkIf cfg.enable {
    services.croc = {
      enable = true;
      debug = true;
    };
  };
}
