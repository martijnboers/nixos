{ config, lib, ... }:

with lib;

let
  cfg = config.hosts.wireguard-server;
in
{
  options.hosts.wireguard-server = {
    enable = mkEnableOption "Wireguard with variable floatingIP";

    floatingIP = mkOption {
      type = types.str;
      description = "The Hetzner Floating IPv4 address to use for this endpoint.";
      example = "198.51.100.123";
    };

    mainInterface = mkOption {
      type = types.str;
      default = "enp1s0";
      description = "The server's main physical network interface.";
    };

    wireguardConfig = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        The configuration for the WireGuard interface itself (private key, peers, etc.).
        This should match the structure found in 'networking.wireguard.interfaces.<name>'.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.interfaces = {
      lo.ipv4.addresses = [
        {
          address = cfg.floatingIP;
          prefixLength = 32;
        }
      ];
    };

    # Create the actual WireGuard interface using the user-provided settings.
    networking.wireguard.interfaces."wg-exit" = cfg.wireguardConfig;

    # Part 2: Force outbound traffic to use the Floating IP.
    networking.firewall = {
      enable = true;
      # extraPostroutingRules = ''
      #   -o ${cfg.mainInterface} -j SNAT --to-source ${cfg.floatingIP}
      # '';
    };
  };
}
