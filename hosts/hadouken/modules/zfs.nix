{...}: {
  # ZFS datasets
  fileSystems."/mnt/zwembad/music" = {
    device = "zwembad/music";
    fsType = "zfs";
  };
  fileSystems."/mnt/zwembad/hot" = {
    device = "zwembad/hot";
    fsType = "zfs";
  };
  fileSystems."/mnt/zwembad/app" = {
    device = "zwembad/app";
    fsType = "zfs";
  };

  services.zfs = {
    autoScrub.enable = true;
    zed.settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

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
  };

  services.syncoid = {
    enable = true;

    # 3:14am daily
    interval = "*-*-* 03:14:00";

    commands."apps" = {
      source = "zwembad/app";
      target = "/mnt/garaga/Backups/app";
      extraArgs = [
        "--no-sync-snap"
        "--delete-target-snapshots"
      ];
      localSourceAllow = config.services.syncoid.localSourceAllow ++ ["mount"];
      localTargetAllow = config.services.syncoid.localTargetAllow ++ ["destroy"];
    };
  };
}
