{ ... }:
{
  networking.hostName = "rekkaken";

  imports = [
    ./modules/headscale.nix
    ./modules/caddy.nix
  ];

  hosts.keycloak.enable = true;
  hosts.caddy.enable = true;

  # two of two
  hosts.authdns.enable = true;

  # Enable tailscale network
  hosts.tailscale.enable = true;
  # Enable exit-node features
  services.tailscale.useRoutingFeatures = "server";

  hosts.openssh = {
    enable = true;
    allowUsers = [ "*@100.64.0.0/10" ];
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://iwa7rtli@iwa7rtli.repo.borgbase.com/./repo";
  };

  nix.settings.trusted-users = [ "martijn" ]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
