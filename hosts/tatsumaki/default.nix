{...}: {
  networking.hostName = "tatsumaki";

  imports = [
    ./modules/endlessh.nix
  ];

  hosts.endlessh.enable = true;

  # Enable tailscale network
  hosts.tailscale.enable = true;

  hosts.openssh = {
    enable = true;
    allowUsers = ["*@100.64.0.0/10"];
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://jym6959y@jym6959y.repo.borgbase.com/./repo";
  };

  nix.settings.trusted-users = ["martijn"]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
