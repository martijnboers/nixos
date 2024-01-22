{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.transmission;
in {
  options.hosts.transmission = {
    enable = mkEnableOption "Transmission configuration";
  };

  config = mkIf cfg.enable {
    services = {
      caddy.virtualHosts."transmission.thuis.plebian.nl".extraConfig = ''
        tls internal
        reverse_proxy http://127.0.0.1:${toString config.services.transmission.settings.rpc-port}
      '';
      borgbackup.jobs.default.paths = ["${config.services.transmission.home}/.config/"];
      transmission = {
        enable = true;
        openPeerPorts = true;
        credentialsFile = config.age.secrets.transmission.path;
        downloadDirPermissions = "0777";
        user = "martijn";
        settings = {
          download-dir = "/media";
          umask = 022;
          incomplete-dir-enabled = true;
          rpc-host-whitelist = "transmission.thuis.plebian.nl";
          rpc-host-whitelist-enabled = true;
          rpc-whitelist = "127.0.0.1,100.64.0.*";
          rpc-whitelist-enabled = true;
          rpc-authentication-required = true;
          rpc-bind-address = "127.0.0.1";
        };
      };
    };
  };
}
