{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.matrix;
in {
  options.hosts.matrix = {
    enable = mkEnableOption "Matrix chat federation";
  };

  config = mkIf cfg.enable {
    services.caddy = {
      extraConfig = ''
      matrix.thuis, matrix.thuis:8448 {
        tls {
          issuer internal { ca hadouken }
        }
        @internal {
          remote_ip 100.64.0.0/10
        }
        handle @internal {
           reverse_proxy /_matrix/* http://localhost:${toString config.services.matrix-conduit.settings.global.port}
        }
        respond 403
            }
      '';
    };

    networking.firewall.allowedTCPPorts = [8448];

    services.matrix-conduit = {
      enable = true;
      settings.global = {
        server_name = "plebian.nl";
        allow_check_for_updates = false;
        allow_registration = false;
      };
    };
  };
}
