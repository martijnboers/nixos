{
  config,
  lib,
  pkgs,
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
      default = [ ];
      description = "Auditd rules";
    };
  };

  config = mkIf cfg.enable {
    security = {
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

    age.secrets.gotify-auditd.file = ../../secrets/gotify-auditd.age;

    systemd.services.audit-gotify-notifier = {
      description = "Send Gotify notifications for Login Audit Events";
      after = [
        "network-online.target"
        "auditd.service"
      ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        curl
        gnugrep
        coreutils
        systemd # for journalctl
      ];
      serviceConfig = {
        LoadCredential = "gotify_token:${config.age.secrets.gotify-auditd.path}";
        DynamicUser = true;
        SupplementaryGroups = [ "systemd-journal" ]; # Required to read journalctl
        Restart = "always";
        RestartSec = "5s";
      };
      script = ''
        GOTIFY_URL="https://notifications.thuis" 
        TOKEN=$(cat "$CREDENTIALS_DIRECTORY/gotify_token")

        journalctl -t audit -f -n 0 | grep --line-buffered -E 'op=PAM:(authentication|session_open).*res=(success|failed)' | while read -r line; do

        if ! echo "$line" | grep -qE 'exe=".*(sudo|su|sshd).*"'; then
            continue
        fi

        EXE=$(echo "$line" | grep -o 'exe="[^"]*"' | cut -d'"' -f2 | xargs basename)
        [ -z "$EXE" ] && EXE="Unknown"

        if echo "$line" | grep -q "res=failed"; then
           TITLE="🚨 Auth Failed"
           PRIORITY=8
           
        elif echo "$line" | grep -q "res=success"; then
           if [[ "$EXE" == *"sshd"* ]]; then
               # Ignore SSH 'authentication' success (it happens internally before session_open)
               # We wait for the session to actually open
               if ! echo "$line" | grep -q "op=PAM:session_open"; then continue; fi
           else
               # For sudo/su, 'authentication' is the event we want
               if ! echo "$line" | grep -q "op=PAM:authentication"; then continue; fi
           fi
           
           TITLE="✅ Auth Success"
           PRIORITY=5
        else 
           continue
        fi

        ADDR=$(echo "$line" | grep -o 'addr=[^ ]*' | cut -d'=' -f2 | tr -d '"')
        [ "$ADDR" == "?" ] && ADDR=""
        [ ! -z "$ADDR" ] && TITLE="$TITLE ($ADDR)"

        echo "Sending: $TITLE ($EXE)"

        curl -s -S --connect-timeout 5 --max-time 10 -X POST "$GOTIFY_URL/message?token=$TOKEN" \
          -F "title=$TITLE ($EXE)" \
          -F "message=$line" \
          -F "priority=$PRIORITY" \
          -F "extras[client::display][contentType]=text/markdown"
        
        echo ""
        done
      '';
    };
  };
}
