{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.caddy;
in
{
  options.hosts.caddy = {
    enable = mkEnableOption "Caddy base";
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
    };
  };
}
