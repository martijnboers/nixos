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
        reverse_proxy http://100.64.0.5:${toString config.services.transmission.port}
      '';
      transmission = {
        enable = true; #Enable transmission daemon
        openRPCPort = true;
        settings = {
          download-dir = "/mnt/garage/Music";
          incomplete-dir-enabled = true;
          rpc-bind-address = "100.64.0.5";
        };
      };
    };
  };
}
