{ config, ... }:
{
  networking.hostName = "rekkaken";

  imports = [
    ./modules/headscale.nix
    ./modules/notifs.nix
    ./modules/uptime.nix
    ./modules/caddy.nix
  ];

  hosts.headscale.enable = true;
  hosts.notifications.enable = true;
  hosts.caddy.enable = true;
  hosts.uptime-kuma.enable = true;
  hosts.prometheus.enable = true;
  hosts.tailscale.enable = true;

  hosts.authdns = {
    enable = true;
    master = true;
  };

  age.secrets.vpn-rekkaken.age= {
    file = ../../secrets/;
    owner = "wireguard";
    group = "wireguard";
  };

  hosts.wireguard-server = {
    enable = true;
    floatingIP = config.hidden.wireguard_ip; 
    wireguardConfig = {
      ips = [ "10.100.100.1/24" ];
      privateKeyFile = config.secrets.age.vpn-rekkaken; # 
      listenPort = 51820;
      peers = [
        {
          publicKey = "Hw3sLv+7FpCHDyVfO1XT32YpNN2lQzvQO6czPFe3vig="; # nurma
          allowedIPs = [ "10.100.100.2/32" ];
        }
      ];
    };
  };

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
    ];
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://c4j3xt27@c4j3xt27.repo.borgbase.com/./repo";
  };

  nix.settings.trusted-users = [ "martijn" ]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
