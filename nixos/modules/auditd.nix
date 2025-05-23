{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.auditd;
in
{
  options.hosts.auditd = {
    enable = mkEnableOption "Enable auditd";
    rules = mkOption {
      type = types.listOf types.str;
      description = "Auditd rules";
    };
  };

  config = mkIf cfg.enable {
    security = {
      audit = {
        enable = true;
        rules = cfg.rules;
      };
    };

    services.logrotate = {
      enable = true;
      checkConfig = false; # auth.log is root owned
      settings = {
        header = {
          dateext = true;
        };
        "/var/log/audit/audit.log" = {
          frequency = "daily";
          rotate = 4;
          compress = true;
          missingok = true;
          notifempty = true;
          create = "0600 root root";
          postrotate = "systemctl reload audit";
        };
      };
    };
  };
}
