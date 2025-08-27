{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts."exit-node";
in
{
  options.hosts."exit-node" = {
    enable = lib.mkEnableOption "Standard WireGuard Exit Node";
    floatingIp = mkOption { type = types.str; };
    publicInterface = mkOption { type = types.str; };
    privateKeyFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    networking.interfaces.${cfg.publicInterface}.ipv4.addresses = [
      {
        address = cfg.floatingIp;
        prefixLength = 32;
      }
    ];

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking = {
      # The NAT module automatically creates the necessary SNAT and FORWARD rules.
      nat = {
        enable = true;
        externalInterface = cfg.publicInterface;
        internalInterfaces = [ "wg0" ];
        # Forces the NAT engine to use your floating IP for all outgoing traffic.
        externalIP = cfg.floatingIp;
      };

      # The firewall allows incoming WireGuard connections and forwarding from the VPN.
      firewall = {
        enable = true;
        allowedUDPPorts = [ 51820 ];
        # This declaratively allows traffic from the wg0 interface to be forwarded.
        trustedInterfaces = [ "wg0" ];
        # This single command blocks ALL incoming traffic to the floating IP.
        extraCommands = ''
          iptables -A nixos-fw -d ${cfg.floatingIp} -j DROP
        '';
      };
    };

    networking.wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = cfg.privateKeyFile;
      peers = [
        {
          publicKey = "kB9SFPsFsdma1aHnrHeE+Pz8U0WT67gqwo4e4K7HWDA=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };
}
