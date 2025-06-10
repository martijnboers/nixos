{ ... }:
{
  networking.hostName = "shoryuken";

  imports = [
    ./modules/notifications.nix
    ./modules/uptime-kuma.nix
    ./modules/headscale.nix
    ./modules/endlessh.nix
    ./modules/keycloak.nix
    ./modules/sailing.nix
    ./modules/caddy.nix
    ./modules/pgrok.nix
  ];

  hosts.notifications.enable = true;
  hosts.uptime-kuma.enable = true;
  hosts.headscale.enable = true;
  hosts.keycloak.enable = true;
  hosts.caddy.enable = true;
  hosts.sailing.enable = true;
  hosts.prometheus.enable = true;
  hosts.pgrok.enable = false;
  hosts.endlessh.enable = true;

  # Right order of headscale operations for startup
  systemd.services = {
    caddy.wantedBy = [
      "keycloak.service"
      "headscale.service"
    ];
    keycloak.wantedBy = [ "headscale.service" ];
    headscale.wantedBy = [ "tailscaled.service" ];
  };

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
