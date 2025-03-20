{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.wordpress;
  mann = pkgs.stdenv.mkDerivation {
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
    services.caddy.virtualHosts."wedding.thuis".extraConfig = ''
           tls {
      issuer internal { ca hadouken }
           }
           @internal {
      remote_ip 100.64.0.0/10
           }
           handle @internal {
       reverse_proxy http://localhost:8778
           }
           respond 403
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
          wp-statistics
          gutenberg
          jetpack
          contact-form-7
          drag-and-drop-multiple-file-upload-contact-form-7
          flamingo
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
    services.borgbackup.jobs.default.paths = [
      "/var/lib/smtp-to-storage"
      "/var/lib/wordpress/kevinandreihana/uploads/"
    ];

    systemd.tmpfiles.rules = [
      "d /var/lib/smtp-to-storage 0700 smtp-to-storage smtp-to-storage"
    ];

    systemd.services.smtp-to-storage = {
      wantedBy = ["multi-user.target"];
      description = "smtp bridge attachments";
      serviceConfig = {
        Type = "simple";
        ExecStart = getExe pkgs.smtp-to-storage;
        TimeoutStartSec = 600;
        Restart = "on-failure";
        NoNewPrivileges = true;
      };
    };
  };
}
