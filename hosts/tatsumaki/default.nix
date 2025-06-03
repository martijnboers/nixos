{ lib, ... }:
{
  networking.hostName = "tatsumaki";

  imports = [
    ./modules/crypto.nix
    ./modules/caddy.nix
  ];

  hosts.tailscale.enable = true;
  hosts.prometheus.enable = true;
  hosts.caddy.enable = true;

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
      "*@10.10.0.0/24"
    ];
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://jym6959y@jym6959y.repo.borgbase.com/./repo";
  };

  fileSystems =
    let
      mkNfsShare = name: {
        device = "hadouken.machine.thuis:/${name}";
        fsType = "nfs";
        options = [
          "rsize=1048576" # bigger read+write sizes
          "wsize=1048576" # good for bigger files
          "x-systemd.automount"
          "_netdev" # this makes the .mount unit require network-online.target
        ];
      };
    in
    {
      "/mnt/bitcoin" = mkNfsShare "bitcoin";
      "/mnt/fulcrum" = mkNfsShare "fulcrum";
    };

  systemd.services.bitcoind = {
    requires = [ "mnt-bitcoin.mount" ];
    after = [
      "mnt-bitcoin.mount"
      "tailscaled.service"
    ];
  };

  boot.supportedFilesystems = [ "nfs" ];
  nix.settings.trusted-users = [ "martijn" ]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
