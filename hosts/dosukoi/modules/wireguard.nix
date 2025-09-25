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
        group = "root";
        mode = "0400";
      };
    };

    networking.wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets.wireguard-server.path;
        peers = [
          {
            publicKey = "CX8EAGXjMZfmFdtPe+rEyOOOAY2X+9k+Fck/PZkYWlA="; # paddy
            allowedIPs = [ "10.100.0.2/32" ];
          }
          {
            publicKey = "1fcInDMXsy/WHmJn47YAvs7kXGqWbQCTYVGTtFeh61c="; # donk
            allowedIPs = [ "10.100.0.3/32" ];
          }
          {
            publicKey = "1fcInDMXsy/WHmJn47YAvs7kXGqWbQCTYVGTtFeh61c="; # ann
            allowedIPs = [ "10.100.0.4/32" ];
          }
        ];
      };
    };
  };
}
