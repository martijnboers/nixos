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
    users.groups.multimedia.members = [
      "syncthing"
      "jellyfin"
      "martijn"
      "radarr"
      "sonarr"
    ];

    # written files should be r+w for groups
    systemd.services = {
      syncthing.serviceConfig.UMask = "0002";
      sonarr.serviceConfig.UMask = "0002";
      radarr.serviceConfig.UMask = "0002";
    };

    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
      # For QUIC/UDP Buffer Size
      "net.core.rmem_max" = 2500000;
      "net.core.wmem_max" = 2500000;
    };

    systemd.tmpfiles.rules = [
      # Type, Path,                       Mode, Owner,    Group,      Age, Argument
      "d /mnt/zwembad/hot/Downloads -     2775  martijn   multimedia  -    -"
      "d /mnt/zwembad/hot/Movies    -     2775  martijn   multimedia  -    -"
      "d /mnt/zwembad/hot/Series    -     2775  martijn   multimedia  -    -"
      "d /mnt/zwembad/music         -     2775  martijn   multimedia  -    -"
    ];

    services = {
      jellyfin.enable = true;
      jellyseerr.enable = true;

      caddy.virtualHosts."syncthing.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://${config.services.syncthing.guiAddress}
        }
        respond 403
      '';

      borgbackup.jobs.default.paths = [
        config.services.prowlarr.dataDir
        config.services.radarr.dataDir
        config.services.sonarr.dataDir
        config.services.jellyfin.dataDir
        config.services.jellyseerr.configDir
      ];

      prowlarr = {
        enable = true;
        settings.server.bindaddress = "127.0.0.1";
      };

      syncthing = {
        enable = true;
        openDefaultPorts = true;
        dataDir = "/mnt/zwembad/app/syncthing";
        configDir = "/mnt/zwembad/app/syncthing/.config/syncthing";
        overrideDevices = true;
        group = "multimedia";
        overrideFolders = true;
        guiAddress = "127.0.0.1:8384";
        settings = {
          options = {
            urAccepted = 1;
            relaysEnabled = false;
            localAnnounceEnabled = false;
            crashReportingEnabled = false;
          };
          gui.insecureSkipHostcheck = true; # reverse proxy
          devices = {
            "seed".id = "C3CPMI7-DKDUEYC-ALWM3HN-X37N7S7-DNECILF-UUAX4TY-6F7QLEZ-Q7HSTQV";
            "hadouken".id = "AVHC54J-6NTZ6SS-Y5UUYLZ-LE4QIZ5-AGZAUON-2VWB4XW-2O7W3HV-6MIGTQK";
          };
          folders = {
            "hot" = {
              path = "/mnt/zwembad/hot/Downloads";
              ignorePerms = true;
              devices = [
                "seed"
                "hadouken"
              ];
            };
            "music" = {
              path = "/mnt/zwembad/music";
              ignorePerms = true;
              devices = [
                "seed"
                "hadouken"
              ];
            };
          };
        };
      };

      caddy.virtualHosts = {
        "media.thuis" = {
          extraConfig = mkProxy 8096;
        };
        "jelly.thuis" = {
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
    // (genAttrs [ "radarr" "sonarr" ] (name: {
      enable = true;
      group = "multimedia";
      settings.server.bindaddress = "127.0.0.1";
    }));
  };
}
