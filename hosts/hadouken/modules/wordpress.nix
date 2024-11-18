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
  mann = pkgs.stdenv.mkDerivation rec {
    name = "mann";
    src = pkgs.fetchFromGitHub {
      owner = "Automattic";
      repo = "themes";
      rev = "0dfbc4115ad521c68e5bc695997e3ffe918e2940";
      hash = "sha256-ILDIx0fjmmD3YHr03g1A85Z6AeLCSr5EpeVim6wNYeg=";
    };
    installPhase = "mkdir -p $out; cp -R mann $out/";
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
        inherit mann;
        inherit
          (pkgs.fork.wordpressPackages.themes)
          bibimbap
          ;
      };
      settings = {
        # Needed to run behind reverse proxy
        FORCE_SSL_ADMIN = true;
        WP_DEFAULT_THEME = "mann";
      };
      plugins = {
        inherit
          (pkgs.fork.wordpressPackages.plugins) # from own fork
          antispam-bee
          wp-file-upload
          wp-statistics
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
