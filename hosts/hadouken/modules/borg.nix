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
    services.borgbackup.jobs.home-hadouken = {
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.age.secrets.borg.path}";
      };
      environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i /home/martijn/.ssh/id_ed25519";
      repo = "ssh://gak69wyz@gak69wyz.repo.borgbase.com/./repo";
      compression = "auto,zstd";
      startAt = "daily";
      user = "root";
    };
  };
}
