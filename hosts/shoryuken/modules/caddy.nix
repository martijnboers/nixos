{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.caddy;
in {
  options.hosts.caddy = {
    enable = mkEnableOption "Caddy base";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.caddy = {
      enable = true;
      virtualHosts."cloud.plebian.nl".extraConfig = ''
        respond "☁️"
      '';
      virtualHosts."whichmarket.online".extraConfig = ''
        respond "👷🏻‍♂️"
      '';
    };
  };
}
