{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.borg;
in {
  options.hosts.borg = {
    enable = mkEnableOption "Make backups of host";
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs.home-glassdoor = {
      paths = "/home/martijn";
      encryption.mode = "none";
      environment.BORG_RSH = "ssh -i /home/martijn/.ssh/id_ed25519";
      repo = "ssh://martijn@192.168.1.156:666/192.168.1.156/mnt/garage/Backup/borg/home-glassdoor";
      compression = "auto,zstd";
      startAt = "daily";
      exclude = [
        # Largest cache dirs
        ".cache"
        "*/cache2" # firefox
        "*/Cache"
        ".config/Slack/logs"
        ".config/Code/CachedData"
        ".container-diff"
        ".npm/_cacache"
        # Work related dirs
        "*/node_modules"
        "*/bower_components"
        "*/_build"
        "*/.tox"
        "*/venv"
        "*/.venv"
      ];
    };
  };
}
