{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.atuin;
in {
  options.hosts.atuin = {
    enable = mkEnableOption "Synchronize zsh history files";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."atuin.thuis.plebian.nl".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.atuin.port}
    '';
    services.atuin = {
      enable = true;
      openRegistration = false;
      port = 8965;
    };
  };
}
