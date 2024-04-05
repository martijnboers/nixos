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
        reverse_proxy http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}
      }
      respond 403
    '';
    services.borgbackup.jobs.default.paths = [
      "${config.services.grafana.settings.database.path}"
    ];
    services.grafana = {
      enable = true;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
            }
          ];
        }
        {
          job_name = "caddy";
          static_configs = [
            {
              # caddy api endpoint
              targets = ["127.0.0.1:2019"];
            }
          ];
        }
      ];

      settings = {
        server = {
          domain = "monitoring.thuis.plebian.nl";
          http_port = 2342;
          http_addr = "127.0.0.1";
        };
      };
    };

    services.prometheus = {
      enable = true;
      port = 9001;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9002;
        };
      };
    };
  };
}
