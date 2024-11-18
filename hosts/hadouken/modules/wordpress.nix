{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.wordpress;
  wordpress-theme-vows = pkgs.stdenv.mkDerivation rec {
    name = "vows";
    version = "1.2";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/theme/vows.${version}.zip";
      hash = "sha256-nrarZhdgpAdeENnoa84wvNzYLqekVUVYZV763b6yQac=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };
  wordpress-plugin-pinterest = pkgs.stdenv.mkDerivation rec {
    name = "pinterest";
    version = "1.8.8";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/plugins/gs-pinterest-portfolio.${version}.zip";
      hash = "sha256-/9X+jWajbPB/ofXybkuiPo3JWeb6JvEmdG771euQVVk=";
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

    services.phpfpm.pools."wordpress-kevinandreihana".phpOptions = ''
      upload_max_filesize=1G
      post_max_size=1G
    '';

    services.wordpress.sites."kevinandreihana" = {
      themes = {
        mann = pkgs.wp-themes;
      };
      settings = {
        # Needed to run behind reverse proxy
        FORCE_SSL_ADMIN = true;
        WP_DEFAULT_THEME = "mann";
      };
      plugins = {
        inherit wordpress-plugin-pinterest;
        inherit
          (pkgs.wordpressPackages.plugins)
          antispam-bee
          forminator
          gutenberg
          jetpack
          ;
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
