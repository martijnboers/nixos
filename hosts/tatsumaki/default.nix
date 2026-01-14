{ ... }:
{
  networking.hostName = "tatsumaki";

  imports = [
    ./modules/bitcoin.nix
    ./modules/caddy.nix
  ];

  hosts.tailscale.enable = true;
  hosts.prometheus.enable = true;
  hosts.caddy.enable = true;

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
      "*@10.30.0.0/24"
    ];
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://jym6959y@jym6959y.repo.borgbase.com/./repo";
  };

  security = {
    sudo.enable = true;
    sudo-rs.enable = false;
  }; # sudo-rs doesn't play nice with nix-bitcoin

  boot.supportedFilesystems = [ "nfs" ];
  nix.settings.trusted-users = [ "martijn" ]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
