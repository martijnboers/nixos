{ modulesPath, ... }:
{
  networking.hostName = "tatsumaki";

  imports = [
    ./modules/endlessh.nix
    ./modules/trap.nix
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix
    (modulesPath + "/profiles/hardened.nix")
  ];

  hosts.endlessh.enable = true;
  hosts.trap.enable = true;

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

  nix.settings.trusted-users = [ "martijn" ]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
