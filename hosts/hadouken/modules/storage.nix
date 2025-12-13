{ options, ... }:
{
  # ----- FAST-STORAGE -----
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

  # ----- New disk -----
  fileSystems."/mnt/zolder/cold" = {
    device = "zolder/cold";
    fsType = "zfs";
  };
  fileSystems."/mnt/zolder/misc" = {
    device = "zolder/misc";
    fsType = "zfs";
  };

  # ----- Broken disk -----
  fileSystems."/mnt/garage/cold" = {
    device = "garage/cold";
    fsType = "zfs";
  };
  fileSystems."/mnt/garage/misc" = {
    device = "garage/misc";
    fsType = "zfs";
  };

  # ----- Snapshots -----
  # Only mount when syncoid created datasets
  fileSystems."/mnt/garage/backups/app" = {
    device = "garage/backups/app";
    fsType = "zfs";
  };
  fileSystems."/mnt/garage/backups/music" = {
    device = "garage/snapshots/music";
    fsType = "zfs";
  };
  fileSystems."/mnt/garage/backups/share" = {
    device = "garage/backups/share";
    fsType = "zfs";
  };
  fileSystems."/mnt/zolder/backups/app" = {
    device = "zolder/backups/app";
    fsType = "zfs";
  };
  fileSystems."/mnt/zolder/backups/music" = {
    device = "zolder/backups/music";
    fsType = "zfs";
  };
  fileSystems."/mnt/zolder/backups/share" = {
    device = "zolder/backups/share";
    fsType = "zfs";
  };

  services.zfs.autoScrub.enable = true;

  services.syncoid = {
    enable = true;

    # 3:14am daily
    interval = "*-*-* 03:14:00";

    commands."apps-garage" = {
      source = "zwembad/app";
      target = "garage/backups/app";
    };
    commands."apps-zolder" = {
      source = "zwembad/app";
      target = "zolder/backups/app";
    };

    commands."music-garage" = {
      source = "zwembad/music";
      target = "garage/backups/music";
    };
    commands."music-zolder" = {
      source = "zwembad/music";
      target = "zolder/backups/app";
    };

    commands."share-garage" = {
      source = "zwembad/share";
      target = "garage/backups/share";
    };
    commands."share-zolder" = {
      source = "zwembad/share";
      target = "zolder/backups/share";
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
