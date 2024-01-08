{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.caddy;
  plebianRepo = builtins.fetchGit {
    url = "https://github.com/martijnboers/plebian.nl.git";
  };
in {
  options.hosts.caddy = {
    enable = mkEnableOption "caddy with default websites loaded";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.caddy = {
      enable = true;
      virtualHosts."plebian.nl".extraConfig = ''
        root * ${plebianRepo}/
        encode zstd gzip
        file_server
      '';
      virtualHosts."noisesfrom.space".extraConfig = ''
        reverse_proxy http://localhost:${toString config.services.vaultwarden.config.rocketPort}
      '';
      virtualHosts."atuin.plebian.nl".extraConfig = ''
        reverse_proxy http://localhost:${toString config.services.atuin.port}
      '';
      virtualHosts."${config.services.nextcloud.hostName}".extraConfig = ''
        root * ${config.services.nextcloud.package}
         root /store-apps/* ${config.services.nextcloud.home}
         root /nix-apps/* ${config.services.nextcloud.home}
         encode zstd gzip

         php_fastcgi unix//${config.services.phpfpm.pools.nextcloud.socket}
         file_server

         header {
           Strict-Transport-Security max-age=31536000;
         }

         redir /.well-known/carddav /remote.php/dav 301
         redir /.well-known/caldav /remote.php/dav 301
      '';
    };
  };
}
