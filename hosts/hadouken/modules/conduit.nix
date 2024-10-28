{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.conduit;
in {
  options.hosts.conduit = {
    enable = mkEnableOption "Matrix chat federation";
  };

  config = mkIf cfg.enable {
    services.caddy = {
      extraConfig = ''
        matrix.plebian.nl, matrix.plebian.nl:8448 {
            reverse_proxy /_matrix/* http://localhost:${toString config.services.matrix-conduit.settings.global.port}
        }
      '';
      virtualHosts."plebian.nl".extraConfig = ''
        reverse_proxy /.well-known/matrix/* http://localhost:${toString config.services.matrix-conduit.settings.global.port}
      '';
    };

    networking.firewall.allowedTCPPorts = [8448];

    services.matrix-conduit = {
      enable = true;
      settings.global = {
        server_name = "plebian.nl";
        allow_check_for_updates = false;
        allow_registration = false;
        well_known = {
          server = "matrix.plebian.nl:443";
          client = "https://matrix.plebian.nl";
        };
      };
    };
  };
}
