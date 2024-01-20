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
        reverse_proxy http://127.0.0.1:${toString config.services.transmission.settings.rpc-port}
      '';
      transmission = {
        enable = true; #Enable transmission daemon
        openPeerPorts = true;
        settings = {
          download-dir = "/mnt/garage/Music";
          incomplete-dir-enabled = true;
          rpc-bind-address = "127.0.0.1";
        };
      };
    };
  };
}
