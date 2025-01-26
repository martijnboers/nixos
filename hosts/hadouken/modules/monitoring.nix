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
    services.caddy.virtualHosts."monitoring.thuis".extraConfig = ''
      tls {
        issuer internal { ca hadouken }
      }
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}
      }
      respond 403
    '';
    services.borgbackup.jobs.default.paths = [config.services.grafana.settings.database.path];
    services.grafana = {
      enable = true;
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
          }
        ];
      };
      settings = {
        server = {
          domain = "monitoring.thuis";
          http_port = 2342;
          http_addr = "127.0.0.1";
        };
        analytics.reporting_enabled = false;
      };
      declarativePlugins = with pkgs.grafanaPlugins; [grafana-piechart-panel];
    };

    services.loki = {
      enable = true;
      configuration = {
        server.http_listen_port = 3030;
        auth_enabled = false;
        analytics.reporting_enabled = false;

        common = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
          path_prefix = "/tmp/loki";
        };

        schema_config = {
          configs = [
            {
              from = "2020-05-15";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };
        storage_config.filesystem.directory = "/var/lib/loki/chunk";
      };
    };

    # Add promtail to access access logs
    users.users.promtail.extraGroups = [config.services.caddy.group];

    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [
          {
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
          }
        ];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = "hadouken";
              };
            };
            relabel_configs = [
              {
                source_labels = ["__journal__systemd_unit"];
                target_label = "unit";
              }
            ];
          }
          {
            job_name = "caddy";
            static_configs = [
              {
                targets = ["localhost"];
                labels = {
                  job = "caddy";
                  __path__ = "/var/log/caddy/*log";
                  agent = "caddy-promtail";
                };
              }
            ];
          }
        ];
      };
    };

    services.influxdb = {
      enable = true;
      package = pkgs.stable.influxdb;
    };

    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets =
                map (host: "${host}.machine.thuis:${toString config.services.prometheus.exporters.node.port}")
                ["hadouken" "shoryuken" "tenshin" "glassdoor"];
            }
          ];
        }
        {
          job_name = "caddy";
          static_configs = [
            {
              targets = ["127.0.0.1:2019"];
            }
          ];
        }
        {
          job_name = "endlessh";
          static_configs = [
            {
              targets = ["tenshin.machine.thuis:${toString config.services.endlessh-go.prometheus.port}"];
            }
          ];
        }
        {
          job_name = "adguard";
          static_configs = [
            {
              targets = ["tenshin.machine.thuis:9617"];
            }
          ];
        }
        {
          job_name = "bitcoind";
          static_configs = [
            {
              targets = ["hadouken.machine.thuis:9332"];
            }
          ];
        }
        {
          job_name = "zfs";
          static_configs = [
            {
              targets = ["127.0.0.1:2020"];
            }
          ];
        }
      ];
      exporters = {
        zfs = {
          enable = true;
          port = 2020;
        };
      };
    };
  };
}
