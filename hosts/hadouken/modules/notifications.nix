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
      description = "hydroxide";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe pkgs.hydroxide} smtp";
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
        port = 465;
        tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
        tls = "on";
        auth = "login";
        tls_starttls = "off";
      };
      accounts = {
        default = {
          host = "localhost";
          port = 1025;
          passwordeval = "cat ${toString config.age.secrets.caddy.path}";
          user = "monitoring@plebian.nl";
          from = "monitoring@plebian.nl";
        };
      };
    };
  };
}
