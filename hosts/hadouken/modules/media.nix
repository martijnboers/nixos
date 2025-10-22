{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.media;
in
{
  options.hosts.media = {
    enable = mkEnableOption "jellyfin";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "media.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://127.0.0.1:8096
        }
        respond 403
      '';
      "radarr.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://127.0.0.1:${toString config.services.radarr.settings.server.port}
        }
        respond 403
      '';
      "sonarr.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://127.0.0.1:${toString config.services.sonarr.settings.server.port}
        }
        respond 403
      '';
      "media-stats.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://127.0.0.1:${toString config.services.jellyseerr.port}
        }
        respond 403
      '';
    };

    services = {
      jellyfin.enable = true;
      jellyseerr.enable = true;
      radarr = {
        enable = true;
        settings.server = {
          bindaddress = "127.0.0.1";
        };
      };
      sonarr = {
        enable = true;
        settings.server = {
          bindaddress = "127.0.0.1";
        };
      };
    };
  };
}
