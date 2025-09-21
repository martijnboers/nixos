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
      default = [];
      description = "Auditd rules";
    };
  };

  config = mkIf cfg.enable {
    security = {
      auditd.enable = true;
      audit = {
        enable = true;
        rules = cfg.rules ++ [
          "-w /var/log/wtmp -p wa -k successful_logins"
          "-w /var/log/btmp -p wa -k failed_logins"
          "-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=-1 -F dir=/var/log/ -k log_tampering"
        ];
        backlogLimit = 8192;
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
          size = "50M";
          frequency = "daily";
          rotate = 7;
          compress = true;
          missingok = true;
          notifempty = true;
          create = "0600 root root";
          postrotate = "systemctl restart auditd";
        };
      };
    };
  };
}
