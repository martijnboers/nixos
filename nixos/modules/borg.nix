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
    repository = mkOption {
      type = types.str;
      description = "Repository link";
    };
    exclude = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Exclude these paths";
    };
    paths = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Include these paths";
    };
    identityPath = mkOption {
      type = types.str;
      default = "/home/martijn/.ssh/id_ed25519";
      description = "Which key to use";
    };
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs.default = {
      paths = cfg.paths;
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.age.secrets.borg.path}";
      };
      environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${cfg.identityPath}";
      repo = cfg.repository;
      compression = "auto,zstd";
      startAt = "daily";
      user = "root";
      exclude = cfg.exclude;
    };
  };
}
