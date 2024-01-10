{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.wireguard;
in {
  options.hosts.wireguard = {
    enable = mkEnableOption "VPN server";
  };

  config = mkIf cfg.enable {
    age.secrets.wireguard-private.file = ../../../secrets/wireguard.age;

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = true;
    };
    networking = {
      nat = {
        enable = true;
        externalInterface = "enp114s0";
        internalInterfaces = ["wg0"];
      };
      firewall = {
        allowedUDPPorts = [51820];
        extraCommands = ''
          iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o enp114s0 -j MASQUERADE
          iptables -A FORWARD -i wg0 -j ACCEPT
          iptables -A FORWARD -o wg0 -j ACCEPT
        '';
      };
      wireguard.interfaces = {
        wg0 = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = ["10.100.0.1/24"];

          # The port that WireGuard listens to. Must be accessible by the client.
          listenPort = 51820;

          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
          '';

          # This undoes the above command
          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
          '';

          privateKeyFile = config.age.secrets.wireguard-private.path;

          peers = [
            {
              publicKey = "leYqIMi+70zOgLLiUbjh54Q9jaqXrKBCiq5Jev4GPjs=";
              # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
              allowedIPs = ["10.100.0.2/32"];
            }
          ];
        };
      };
    };
  };
}
