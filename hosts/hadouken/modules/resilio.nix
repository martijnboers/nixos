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

    networking.firewall.allowedTCPPorts = [9001];
    networking.firewall.allowedUDPPorts = [9001];

    services.resilio = {
      enable = true;
      deviceName = "hadouken";
      enableWebUI = true;
      httpLogin = "martijn";
      listeningPort = 9001;
      httpListenAddr = "0.0.0.0";
    };
  };
}
