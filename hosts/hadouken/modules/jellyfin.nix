{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.jellyfin;
in {
  options.hosts.jellyfin = {
    enable = mkEnableOption "Jellyfin";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."jelly.plebian.nl".extraConfig = ''
      reverse_proxy http://127.0.0.1:8096
    '';
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      dataDir = "/mnt/zwembad/app/jellyfin";
    };
  };
}
