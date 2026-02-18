{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.garage;
in
{
  options.hosts.garage = {
    enable = mkEnableOption "Garage Object Storage";
  };

  config = mkIf cfg.enable {
    services.garage = {
      enable = true;
      package = pkgs.garage;
      settings = {
        metadata_dir = "/var/lib/garage/meta";
        data_dir = "/mnt/zwembad/games/garage";
        db_engine = "sqlite";

        replication_factor = 1;

        rpc_bind_addr = "[::]:3901";
        rpc_public_addr = "127.0.0.1:3901";

        s3_api = {
          s3_region = "thuis";
          api_bind_addr = "[::]:3900";
          root_domain = ".s3.garage.thuis";
        };

        s3_web = {
          bind_addr = "[::]:3902";
          root_domain = ".web.garage.thuis";
          index = "index.html";
        };

        admin = {
          api_bind_addr = "[::]:3903";
        };
      };
      environmentFile = config.age.secrets.garage.path;
    };

    environment.systemPackages = [ pkgs.garage-webui ];

    systemd.services.garage-webui = {
      enable = true;
      description = "Garage Web UI";
      after = [ "garage.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "garage";
        Group = "garage";
        ExecStart = "${pkgs.garage-webui}/bin/garage-webui";
        Restart = "on-failure";
        Environment = [
          "GARAGE_WEBUI_LISTEN=127.0.0.1:3909"
          "GARAGE_WEBUI_GARAGE_API=http://localhost:3903"
        ];
        EnvironmentFile = config.age.secrets.garage.path;
      };
    };

    age.secrets.garage = {
      file = ../../../secrets/garage.age;
      owner = "garage";
      group = "garage";
    };

    services.caddy.virtualHosts = {
      "garage.thuis".extraConfig = ''
        import headscale
        handle @internal {
          handle_path /admin/* {
            reverse_proxy http://localhost:3903
          }

          handle_path /webui/* {
            reverse_proxy http://localhost:3909
          }

          handle {
            reverse_proxy http://localhost:3900
          }
        }
        respond 403
      '';
    };
  };
}
