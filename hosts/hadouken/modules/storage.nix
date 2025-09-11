{ options, ... }:
{
  fileSystems."/mnt/zwembad/app" = {
    device = "zwembad/app";
    fsType = "zfs";
  };
  fileSystems."/mnt/zwembad/share" = {
    device = "zwembad/share";
    fsType = "zfs";
  };
  fileSystems."/mnt/zwembad/music" = {
    device = "zwembad/music";
    fsType = "zfs";
  };
  fileSystems."/mnt/zwembad/games" = {
    device = "zwembad/games";
    fsType = "zfs";
  };
  fileSystems."/mnt/zwembad/hot" = {
    device = "zwembad/hot";
    fsType = "zfs";
  };

  fileSystems."/mnt/garage/cold" = {
    device = "garage/cold";
    fsType = "zfs";
  };
  fileSystems."/mnt/garage/misc" = {
    device = "garage/misc";
    fsType = "zfs";
  };

  # Only mount when syncoid has created the datasets
  fileSystems."/mnt/garage/backups/app" = {
    device = "garage/backups/app";
    fsType = "zfs";
  };
  fileSystems."/mnt/garage/backups/music" = {
    device = "garage/backups/music";
    fsType = "zfs";
  };
  fileSystems."/mnt/garage/backups/share" = {
    device = "garage/backups/share";
    fsType = "zfs";
  };

  services.zfs.autoScrub.enable = true;

  services.syncoid = {
    enable = true;

    # 3:14am daily
    interval = "*-*-* 03:14:00";

    commands."apps" = {
      source = "zwembad/app";
      target = "garage/backups/app";
    };
    commands."music" = {
      source = "zwembad/music";
      target = "garage/backups/music";
    };
    commands."share" = {
      source = "zwembad/share";
      target = "garage/backups/share";
    };

    # https://github.com/NixOS/nixpkgs/issues/216614#issuecomment-1567519369
    localSourceAllow = options.services.syncoid.localSourceAllow.default ++ [
      "mount"
    ];
    localTargetAllow = options.services.syncoid.localTargetAllow.default ++ [
      "destroy"
    ];
  };
}
