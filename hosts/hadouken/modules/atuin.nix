{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.atuin;
  plebianRepo = builtins.fetchGit {
    url = "https://github.com/martijnboers/plebian.nl.git";
  };
in {
  options.hosts.atuin = {
    enable = mkEnableOption "caddy with default websites loaded";
  };

  config = mkIf cfg.enable {
      services.atuin = {
        enable = true;
        openRegistration = false;
        port = 8965;
      };
  };
}
