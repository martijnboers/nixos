{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.resilio;
in {
  options.hosts.resilio = {
    enable = mkEnableOption "Resilio syncing seed";
    name = mkOption {
      type = types.str;
      description = "Name of the device";
    };
  };

  config = mkIf cfg.enable {
    users.users.martijn.extraGroups = ["rslsync"];

    networking.firewall.allowedTCPPorts = [55555];
    networking.firewall.allowedUDPPorts = [55555];

    services.resilio = {
      deviceName = cfg.name;
      enable = true;
      enableWebUI = true;
      httpLogin = "admin";
      httpPass = "admin";
      httpListenAddr = "0.0.0.0";
      listeningPort = 55555;
    };
  };
}
