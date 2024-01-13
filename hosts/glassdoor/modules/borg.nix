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
      paths = ["/home/martijn"];
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.age.secrets.borg.path}";
      };
      environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i /home/martijn/.ssh/id_ed25519";
      repo = "myg0b6y7@myg0b6y7.repo.borgbase.com:repo";
      compression = "auto,zstd";
      startAt = "daily";
      user = "martijn";
      exclude = [
        ".cache"
        "*/cache2" # firefox
        "*/Cache"
        ".config/Slack/logs"
        ".config/Code/CachedData"
        ".container-diff"
        ".npm/_cacache"
        "*/node_modules"
        "*/_build"
        "*/venv"
        "*/.venv"
        "~/.local"
        "~/Downloads"
        "~/Data"
      ];
    };
  };
}
