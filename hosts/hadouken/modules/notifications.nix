{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.notifications;
in {
  options.hosts.notifications = {
    enable = mkEnableOption "Open source proton bridge";
  };

  config = mkIf cfg.enable {
    # First authenticate
    # hydroxide auth <username>
    environment.systemPackages = with pkgs; [hydroxide];

systemd.services.hydroxide = {
    enable = true;
    wantedBy = ["multi-user.target"];
    description = "A third-party, open-source ProtonMail bridge";

    serviceConfig = {
      User = "notoh";
      ExecStart = "${pkgs.hydroxide}/bin/hydroxide -disable-carddav smtp";
      Restart = "always";
      RestartSec = 30;
    };
  };

    age.secrets.email.file = ../../../secrets/email.age;

    environment.etc."aliases".text = ''
      root: martijn@plebian.nl
    '';

    programs.msmtp = {
      enable = true;
      setSendmail = true;
      defaults = {
        aliases = "/etc/aliases";
        port = 1025;
        tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
        tls = "on";
        auth = "login";
        tls_starttls = "off";
      };
      accounts = {
        default = {
          host = "localhost";
          passwordeval = "cat ${toString config.age.secrets.email.path}";
          user = "monitoring@plebian.nl";
          from = "monitoring@plebian.nl";
        };
      };
    };
  };
}
