{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.auditd;
in {
  options.hosts.auditd = {
    enable = mkEnableOption "Enable auditd";
    rules = mkOption {
      type = types.listOf types.str;
      description = "Auditd rules";
    };
  };

  config = mkIf cfg.enable {
    security = {
      auditd.enable = true;
      audit = {
        enable = true;
        backlogLimit = 8192;
        failureMode = "printk";
        rules = cfg.rules;
      };
    };

    systemd = {
      timers."clean-audit-log" = {
        description = "Periodically clean audit log";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };

      # clean audit log if it's more than 524,288,000 bytes, which is roughly 500 megabytes
      # it can grow MASSIVE in size if left unchecked
      services."clean-audit-log" = {
        script = ''
          set -eu
          if [[ $(stat -c "%s" /var/log/audit/audit.log) -gt 524288000 ]]; then
            echo "Clearing Audit Log";
            rm -rvf /var/log/audit/audit.log;
            echo "Done!"
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };
  };
}
