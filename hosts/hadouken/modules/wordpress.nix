{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.wordpress;
  wordpress-theme-responsive = pkgs.stdenv.mkDerivation rec {
    name = "vows";
    version = "1.2";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/theme/vows.${version}.zip";
      hash = "sha256-nrarZhdgpAdeENnoa84wvNzYLqekVUVYZV763b6yQac=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };
in {
  options.hosts.wordpress = {
    enable = mkEnableOption "Base for wordpress websites";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."kevinandreihana.com".extraConfig = ''
      reverse_proxy http://localhost:8778
    '';

    services.wordpress.sites."kevinandreihana" = {
      themes = {
        inherit wordpress-theme-responsive;
      };
      settings = {
        # Needed to run behind reverse proxy
        FORCE_SSL_ADMIN = true;
      };
      extraConfig = ''
        $_SERVER['HTTPS']='on';
      '';
      virtualHost.listen = [
        {
          ip = "localhost";
          port = 8778;
        }
      ];
    };
  };
}
