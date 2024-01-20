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
        reverse_proxy http://localhost:${toString config.services.transmission.port}
      '';
      transmission = {
        enable = true; #Enable transmission daemon
        settings = {
          download-dir = "/mnt/garage/Music";
          incomplete-dir-enabled = true;
          rpc-whitelist = "127.0.0.1,192.168.*.*";
          rpc-bind-address = "0.0.0.0";
          rpc-whitelist = "127.0.0.1,10.0.0.1"; #Whitelist your remote machine (10.0.0.1 in this example)
        };
      };
    };
  };
}
