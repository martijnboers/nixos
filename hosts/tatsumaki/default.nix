{ ... }:
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

  fileSystems."/mnt/bitcoin" = {
    device = "hadouken.machine.thuis:/bitcoin";
    fsType = "nfs";
    options = [
      "rsize=1048576" # bigger read+write sizes
      "wsize=1048576" # good for bigger files
      "x-systemd.automount"
      "noauto"
    ];
  };

  boot.supportedFilesystems = [ "nfs" ];

  fileSystems."/mnt/electrs" = {
    device = "hadouken.machine.thuis:/electrs";
    fsType = "nfs";
    options = [
      "rsize=1048576" # bigger read+write sizes
      "wsize=1048576" # good for bigger files
      "x-systemd.automount"
      "noauto"
    ];
  };

  nix.settings.trusted-users = [ "martijn" ]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
