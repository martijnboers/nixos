{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.monitoring;
in {
  options.hosts.monitoring = {
    enable = mkEnableOption "Enable monitoring to host";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."monitoring.thuis.plebian.nl".extraConfig = ''
      tls internal
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://127.0.0.1:${toString config.services.grafana.port}
      }
      respond 403
    '';
    services.borgbackup.jobs.default.paths = [
      "${config.services.grafana.dataDir}"
    ];
    services.grafana = {
      enable = true;
      server = {
        domain = "monitoring.thuis.plebian.nl";
        http_port = 2342;
        http_addr = "127.0.0.1";
      };
    };

    #  # nginx reverse proxy
    #  services.nginx.virtualHosts.${config.services.grafana.domain} = {
    #    locations."/" = {
    #        proxyPass = "http://127.0.0.1:";
    #        proxyWebsockets = true;
    #    };
    #  };
  };
}
