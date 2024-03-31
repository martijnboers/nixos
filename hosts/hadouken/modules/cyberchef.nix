{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.cyberchef;
in {
  options.hosts.cyberchef = {
    enable = mkEnableOption "Development tools";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."tools.thuis.plebian.nl".extraConfig = ''
      tls internal
      root * ${pkgs.cyberchef}/share/cyberchef/"
      encode zstd gzip
      file_server
    '';
  };
}
