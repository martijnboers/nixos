{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.immich;
in
{
  options.hosts.immich = {
    enable = mkEnableOption "Photos viewer";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ immich-go ];
    services.caddy.virtualHosts."immich.thuis".extraConfig = ''
      import headscale
      handle @internal {
        reverse_proxy http://localhost:${toString config.services.immich.port}
      }
      respond 403
    '';
    age.secrets.immich.file = ../../../secrets/immich.age;
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];
    # by default zwembad/app is backed up
    services.borgbackup.jobs.default.paths = [ config.services.immich.mediaLocation ];

    services.immich = {
      enable = true;
      mediaLocation = "/mnt/zwembad/app/immich/upload/";
      environment = {
        IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
      };
    };
  };
}
