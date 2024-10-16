{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.monitoring;
  retentionTime = 30 * 6;
in {
  options.hosts.monitoring = {
    enable = mkEnableOption "Enable monitoring to host";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."monitoring.thuis".extraConfig = ''
      tls internal
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

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {
                store = "inmemory";
              };
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
          max_transfer_retries = 0;
        };

        schema_config = {
          configs = [
            {
              from = "2022-06-06";
              store = "boltdb-shipper";
              object_store = "filesystem";
              schema = "v11";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          boltdb_shipper = {
            active_index_directory = "/var/lib/loki/boltdb-shipper-active";
            cache_location = "/var/lib/loki/boltdb-shipper-cache";
            cache_ttl = "24h";
            shared_store = "filesystem";
          };

          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };

        chunk_store_config = {
          max_look_back_period = "0s";
        };

        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };

        compactor = {
          working_directory = "/var/lib/loki";
          shared_store = "filesystem";
          compactor_ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
      };
      # user, group, dataDir, extraFlags, (configFile)
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

    age.secrets = {
      adguard.file = ../../../secrets/adguard.age;
      tormon.file = ../../../secrets/tormon.age;
    };

    systemd.services = {
      "adguard-exporter" = {
        enable = true;
        description = "AdGuard metric exporter for Prometheus";
        documentation = ["https://github.com/totoroot/adguard-exporter/blob/master/README.md"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          ExecStart = ''
            ${pkgs.adguard-exporter}/bin/adguard-exporter \
                -adguard_hostname 127.0.0.1 -adguard_port ${toString config.services.adguardhome.port} \
                -adguard_username admin -adguard_password $ADGUARD_PASSWORD -log_limit 10000
          '';
          Restart = "on-failure";
          RestartSec = 5;
          NoNewPrivileges = true;
          EnvironmentFile = config.age.secrets.adguard.path;
        };

        "tormon-exporter" = {
          enable = true;
          wantedBy = ["multi-user.target"];
          environment = {
            TORCONTROL_HOST = "100.64.0.1";
            TORCONTROL_PORT = 9051;

            INFLUX_HOST = "127.0.0.1";
            INFLUX_PORT = 8086;
            INFLUX_DB = "tor";
            TAG_HOST = "tornode";
          };
          serviceConfig = {
            ExecStart = lib.getExe pkgs.tormon-exporter;
            Restart = "on-failure";
            RestartSec = 5;
            NoNewPrivileges = true;
            EnvironmentFile = config.age.secrets.tormon.path;
          };
        };
      };
    };

    services.influxdb = {
        enable = true;
        package = pkgs.stable.influxdb;
    };

    services.prometheus = {
      enable = true;
      port = 9001;
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
              targets = ["127.0.0.1:2019"];
            }
          ];
        }
        {
          job_name = "tor";
          static_configs = [
            {
              targets = ["shoryuken.machine.thuis:9052"];
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
              targets = ["127.0.0.1:9617"];
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
      retentionTime = toString retentionTime + "d";
      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9002;
        };
        zfs = {
          enable = true;
          port = 2020;
        };
      };
    };
  };
}
