{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.cyberchef;
in {
  options.hosts.cyberchef = {
    enable = mkEnableOption "Development tools";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."tools.thuis".extraConfig = ''
        tls {
          issuer internal { ca hadouken }
         }
        @internal {
          remote_ip 100.64.0.0/10
        }
        handle @internal {
          root * ${pkgs.cyberchef}/share/cyberchef/
          encode zstd gzip
          file_server
        }
      respond 403
    '';
  };
}
