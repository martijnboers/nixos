{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.caddy;
in {
  options.programs.caddy = {
    enable = mkEnableOption "caddy with default websites loaded";
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts."localhost".extraConfig = ''
        respond "Hello, world!"
      '';
    };
  };
}
