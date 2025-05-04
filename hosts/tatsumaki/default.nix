{ config, ... }:
{
  networking.hostName = "tatsumaki";

  imports = [
    ./modules/crypto.nix
    ./modules/caddy.nix
  ];

  hosts.caddy.enable = false; # TODO

  # Enable tailscale network
  hosts.tailscale.enable = true;

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
    device = "//hadouken.machine.thuis/bitcoin";
    fsType = "cifs";
    options = [
      "uid=1000"
      "gid=100"
      "x-systemd.automount" # lazyloading, solves tailscale chicken&egg
    ];
  };
  nix.settings.trusted-users = [ "martijn" ]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
