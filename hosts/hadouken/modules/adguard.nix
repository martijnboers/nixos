{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.adguard;
in {
  options.hosts.adguard = {
    enable = mkEnableOption "Adguard say no to ads";
  };

  config = mkIf cfg.enable {
  services.caddy.virtualHosts."dns.thuis.plebian.nl".extraConfig = ''
      tls internal
      reverse_proxy http://localhost:${toString config.services.atuin.port}
    '';
    services.adguardhome = {
      enable = true;
    };
  };
}
