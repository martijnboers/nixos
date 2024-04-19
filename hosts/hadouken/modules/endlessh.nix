{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.endlessh;
in {
  options.hosts.endlessh = {
    enable = mkEnableOption "Come join my server";
  };

  config = mkIf cfg.enable {
    services.endlessh-go = {
      enable = true;
      port = 6667;
      prometheus = {
        enable = true;
      };
      openFirewall = true;
    };
  };
}
