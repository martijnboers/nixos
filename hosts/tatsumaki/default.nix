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
        "/mnt/${name}" = {
          device = "hadouken.machine.thuis:/${name}";
          fsType = "nfs";
          options = [
            "rsize=1048576"
            "wsize=1048576"
            "x-systemd.automount"
            "_netdev"
          ];
        };
      };
    in
    lib.attrsets.mergeAttrsList (
      map mkNfsShare [
        "bitcoin"
        "fulcrum"
      ]
    );

  systemd.services.bitcoind = {
    requires = [ "mnt-bitcoin.mount" ];
    after = [
      "mnt-bitcoin.mount"
      "tailscaled.service"
    ];
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
