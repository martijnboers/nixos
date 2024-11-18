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
        matrix.plebian.nl, matrix.plebian.nl:8448 {
            reverse_proxy /_matrix/* http://localhost:${toString config.services.matrix-conduit.settings.global.port}
        }
      '';
      virtualHosts."plebian.nl".extraConfig = ''
        route /.well-known/matrix/server {
            header Access-Control-Allow-Origin "*"
            header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
            header Access-Control-Allow-Headers "X-Requested-With, Content-Type, Authorization"
            respond `{
                "m.server": "matrix.plebian.nl:443"
            }`
        }

        route /.well-known/matrix/client {
            header Access-Control-Allow-Origin "*"
            header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
            header Access-Control-Allow-Headers "X-Requested-With, Content-Type, Authorization"
            respond `{
                "m.homeserver": {
                    "base_url": "https://matrix.plebian.nl"
                }
            }`
        }
      ''; # makes it possible to do @martijn:plebian.nl
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
