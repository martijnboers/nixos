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
    ipaddress = mkOption {
      type = types.str;
      description = "Tailscale IP address of the computer";
    };
    name = mkOption {
      type = types.str;
      description = "Name of the device";
    };
  };

  config = mkIf cfg.enable {
    users.users.martijn.extraGroups = ["rslsync"];

    networking.firewall.allowedTCPPorts = [9000];
    networking.firewall.allowedUDPPorts = [9000];

    services.resilio = {
      deviceName = cfg.name;
      enable = true;
      enableWebUI = true;
      httpListenAddr = "${cfg.ipaddress}";
    };
  };
}
