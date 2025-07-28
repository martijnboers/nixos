{ config, lib, ... }:

with lib;

let
  cfg = config.hosts.wireguard-client;
  publicKey = "yW24DRgU66bN/mJOevf9UuZY1588PGkKUw7UCXxlzAE="; # rekkaken
  endpoint = "rekkaken.machine.thuis:51820";
in
{
  options.hosts.wireguard-client = {
    enable = mkEnableOption "Wireguard client configuration";
    privateKeyFile = mkOption {
      type = types.str;
      description = "Path to this client's unique WireGuard private key.";
      example = "/etc/nixos/secrets/wg-laptop-private-key";
    };
    tunnelAddress = mkOption {
      type = types.str;
      description = "This client's unique static IP address inside the WireGuard tunnel.";
      example = "10.200.200.2/32";
    };
  };

  config = mkIf cfg.enable {
    networking.wireguard.interfaces."wg-exit" = {
      privateKeyFile = cfg.privateKeyFile;
      ips = [ cfg.tunnelAddress ];
      peers = [
        {
          inherit publicKey endpoint;
          persistentKeepalive = 25;
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
        }
      ];
    };
  };
}
