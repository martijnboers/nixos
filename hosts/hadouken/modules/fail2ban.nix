{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.fail2ban;
in {
  options.hosts.fail2ban = {
    enable = mkEnableOption "no thank u";
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      ignoreIP = ["10.10.0.0/24" "100.64.0.0/10"];
      jails = {
        caddy-status = {
          settings = {
            enabled = true;
            port = "http,https";
            filter = "caddy-status";
            logpath = "/var/log/caddy/access-*.log";
            exclude = "/var/log/caddy/access-doornappel.nl.log";
            maxretry = 10;
          };
        };
      };
    };

    environment.etc = {
      "fail2ban/filter.d/caddy-status.conf".text = ''
        [Definition]
        failregex = ^.*"remote_ip":"<HOST>",.*?"status":(?:401|403|500),.*$
        ignoreregex =
        datepattern = LongEpoch
      '';
    };
  };
}
