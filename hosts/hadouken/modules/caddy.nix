{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.caddy;
  plebianRepo = builtins.fetchGit {
    url = "https://github.com/martijnboers/plebian.nl.git";
    rev = "968121cafdaffc23d11eff2b81532ba292a6d65a";
  };
in {
  options.hosts.caddy = {
    enable = mkEnableOption "Caddy with own websites loaded";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.caddy = {
      enable = true;
      virtualHosts."plebian.nl".extraConfig = ''
        root * ${plebianRepo}/
        encode zstd gzip
        file_server
      '';
      virtualHosts."noisesfrom.space".extraConfig = ''
        respond "🦆"
      '';
    };
  };
}
