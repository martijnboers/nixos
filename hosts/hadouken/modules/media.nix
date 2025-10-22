{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.media;
  mkProxy = port: ''
    import headscale
    handle @internal {
      reverse_proxy http://127.0.0.1:${toString port}
    }
    respond 403
  '';

in
{
  options.hosts.media = {
    enable = mkEnableOption "media services";
  };

  config = mkIf cfg.enable {
    services =
      {
        jellyfin.enable = true;
        jellyseerr.enable = true;

        caddy.virtualHosts = {
          "media.thuis" = {
            extraConfig = mkProxy 8096;
          };
          "media-stats.thuis" = {
            extraConfig = mkProxy config.services.jellyseerr.port;
          };
          "radarr.thuis" = {
            extraConfig = mkProxy config.services.radarr.settings.server.port;
          };
          "sonarr.thuis" = {
            extraConfig = mkProxy config.services.sonarr.settings.server.port;
          };
          "prowlarr.thuis" = {
            extraConfig = mkProxy config.services.prowlarr.settings.server.port;
          };
        };
      }
      // (genAttrs [ "radarr" "sonarr" "prowlarr" ] (name: {
        enable = true;
        settings.server.bindaddress = "127.0.0.1";
      }));
  };
}
