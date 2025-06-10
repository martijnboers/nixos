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
            "_netdev" # wait for network-online
            "hard" # Retry indefinitely on server unresponsiveness (good for data)
            "bg" # If the first mount attempt fails, retry in the background.
            "retry=5" # For 'bg', retry for 5 minutes in foreground before backgrounding.
            "timeo=600" # RPC timeout in tenths of a second (e.g., 600 = 60 seconds).
            "retrans=3" # Number of retransmissions before major timeout.
            "x-systemd.mount-timeout=2m" # Tell systemd to wait up to 2 minutes for the mount command to succeed.
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
