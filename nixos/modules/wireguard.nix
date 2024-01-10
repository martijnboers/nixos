{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.wireguard-client;
in {
  options.hosts.wireguard-client = {
    enable = mkEnableOption "Enable wireguard VPN client";
  };

  config = mkIf cfg.enable {
    networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };
  # Enable WireGuard
  networking.wireguard.interfaces = {
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.100.0.2/24" ];
      listenPort = 51820;

      privateKeyFile = config.age.secrets.wireguard-private.path;

      peers = [
        {
          # Public key of the server (not a file path).
          publicKey = "leYqIMi+70zOgLLiUbjh54Q9jaqXrKBCiq5Jev4GPjs=";

          # Forward all the traffic via VPN.
          allowedIPs = [ "0.0.0.0/0" ];

          # Set this to the server IP and port.
          endpoint = "plebian.nl:51820";

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
  };
}
