{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.caddy;
    plebianRepo = builtins.fetchGit {
    url = "https://github.com/martijnboers/plebian.nl.git";
  };
in {
  options.programs.caddy = {
    enable = mkEnableOption "caddy with default websites loaded";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443];

    services.caddy = {
      enable = true;
      virtualHosts."plebian.nl".extraConfig = ''
        root * ${plebianRepo}/public
        encode zstd gzip
        file_server
      '';
    };
  };
}
