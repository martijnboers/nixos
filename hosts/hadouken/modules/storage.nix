{options, ...}: {
  fileSystems."/mnt/zwembad/app" = {
    device = "zwembad/app";
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

  # Only mount when sanoid has created the datasets
  fileSystems."/mnt/garage/backups/app" = {
    label = "app - replica";
    device = "garage/backups/app";
    fsType = "zfs";
  };
  fileSystems."/mnt/garage/backups/music" = {
    label = "music - replica";
    device = "garage/backups/music";
    fsType = "zfs";
  };

  services.zfs = {
    autoScrub.enable = true;
    zed.settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
    };
  };
  services.zfs.zed.enableMail = false;

  services.sanoid = {
    enable = true;
    templates.backup = {
      hourly = 36;
      daily = 30;
      monthly = 3;
      autoprune = true;
      autosnap = true;
    };

    datasets."zwembad/app" = {
      useTemplate = ["backup"];
    };
    datasets."zwembad/music" = {
      useTemplate = ["backup"];
    };
  };

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

    # https://github.com/NixOS/nixpkgs/issues/216614#issuecomment-1567519369
    localSourceAllow = options.services.syncoid.localSourceAllow.default ++ [
      "mount"
    ];
    localTargetAllow = options.services.syncoid.localTargetAllow.default ++ [
      "destroy"
    ];
  };
}
