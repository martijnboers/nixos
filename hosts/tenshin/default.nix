{ lib, ... }:
{
  networking.hostName = "tenshin";

  imports = [
    ./modules/cyberchef.nix
    ./modules/ittools.nix
    ./modules/caddy.nix
    ./modules/ntp.nix
  ];

  hosts.caddy.enable = true;
  hosts.cyberchef.enable = true;
  hosts.it-tools.enable = true;
  hosts.prometheus.enable = true;
  hosts.ntp.enable = true;

  hosts.auditd.enable = false;
  nix-mineral.enable = false;

  hosts.borg = {
    enable = true;
    repository = "ssh://aebp8i08@aebp8i08.repo.borgbase.com/./repo";
  };

  users.users.martijn = {
    hashedPasswordFile = lib.mkForce null;
    hashedPassword = "$y$j9T$VQL/82faMlZSrWg9SefdB/$RQpwhho.v0avZJcjate9yXdzDxVRdBBXeui7ch5XYm9";
  };

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
      "*@10.30.0.0/24"
    ];
  };

  nix.settings.trusted-users = [ "martijn" ]; # allows for remote push

  # Enable tailscale network
  hosts.tailscale.enable = true;

  # Server defaults
  hosts.server.enable = true;
}
