{
  ...
}:
{
  networking.hostName = "dosukoi";

  imports = [
    ./modules/interfaces.nix
    ./modules/wireguard.nix
    ./modules/blocklist.nix
    ./modules/firewall.nix
    ./modules/ntopng.nix
    ./modules/adguard.nix
    ./modules/caddy.nix
  ];

  hosts.borg = {
    enable = true;
    repository = "ssh://llh048o5@llh048o5.repo.borgbase.com/./repo";
  };

  nix.settings.trusted-users = [ "martijn" ]; # allows remote push
  hosts.server.enable = true;
  hosts.adguard.enable = true;
  hosts.caddy.enable = true;
  hosts.ntopng.enable = true;
  hosts.wireguard.enable = true;

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
      "*@10.10.0.0/24"
    ];
  };

  hosts.tailscale.enable = true;
  hosts.prometheus.enable = true;

  age = {
    identityPaths = [ "/home/martijn/.ssh/id_ed25519" ];
  };
}
