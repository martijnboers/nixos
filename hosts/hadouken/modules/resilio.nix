{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.resilio;
in {
  options.hosts.resilio = {
    enable = mkEnableOption "Resilio syncing seed";
  };

  config = mkIf cfg.enable {
    users.users.martijn.extraGroups = ["rslsync"];

    networking.firewall.allowedTCPPorts = [9000];
    networking.firewall.allowedUDPPorts = [9000];

    services.resilio = {
      enable = true;
      deviceName = "hadouken";
      enableWebUI = true;
      listeningPort = 9000;
      httpListenAddr = "0.0.0.0";
    };
  };
}
