{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.wireguard;
in
{
  options.hosts.wireguard = {
    enable = mkEnableOption "wireguard";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      wireguard-server = {
        file = ../../../secrets/wireguard-server.age;
        owner = "root";
        group = "systemd-network";
        mode = "0440";
      };
    };

    boot.kernelModules = [ "wireguard" ];

    systemd.network = {
      netdevs = {
        "50-wg0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
            MTUBytes = "1300";
          };
          wireguardConfig = {
            PrivateKeyFile = config.age.secrets.wireguard-server.path;
            ListenPort = 51820;
          };
          wireguardPeers = [
            {
              PublicKey = "CX8EAGXjMZfmFdtPe+rEyOOOAY2X+9k+Fck/PZkYWlA="; # paddy
              AllowedIPs = [ "10.100.0.2/32" ];
            }
            {
              PublicKey = "1fcInDMXsy/WHmJn47YAvs7kXGqWbQCTYVGTtFeh61c="; # donk
              AllowedIPs = [ "10.100.0.3/32" ];
            }
            {
              PublicKey = "1fcInDMXsy/WHmJn47YAvs7kXGqWbQCTYVGTtFeh61c="; # ann
              AllowedIPs = [ "10.100.0.4/32" ];
            }
          ];
        };
      };
      networks."60-wg0" = {
        matchConfig.Name = "wg0";
        address = [ "10.100.0.1/24" ];
      };
    };

  };
}
