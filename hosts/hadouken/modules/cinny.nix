{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.cinny-web;
in {
  options.hosts.cinny-web = {
    enable = mkEnableOption "Web matrix client";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."chat.thuis".extraConfig = ''
        tls {
          issuer internal { ca hadouken }
        }
        @internal {
          remote_ip 100.64.0.0/10
        }
        handle @internal {
            root * ${pkgs.cinny}
            file_server

            @index {
              not path /index.html
              not path /public/*
              not path /assets/*
              not path /config.json
              not path /manifest.json
              not path /pdf.worker.min.js
              not path /olm.wasm
              path /*
            }

            rewrite /*/olm.wasm /olm.wasm
            rewrite @index /index.html

            # END
        }

      respond 403
    '';
  };
}
