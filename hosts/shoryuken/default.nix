{ config, ... }:
let
  defaultRestart = {
    RestartSec = 10;
  };
in
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
    ./modules/tor.nix
  ];

  hosts.notifications.enable = true;
  hosts.uptime-kuma.enable = true;
  hosts.headscale.enable = true;
  hosts.keycloak.enable = true;
  hosts.caddy.enable = true;
  hosts.tor.enable = true;
  hosts.sailing.enable = true;
  hosts.prometheus.enable = true;
  hosts.pgrok.enable = false;
  hosts.endlessh.enable = true;

  # Right order of headscale operations for startup
  systemd.services.keycloak = {
    after = [ "caddy.service" ];
    requires = [ "caddy.service" ];
    startLimitBurst = 10;
    startLimitIntervalSec = 600;
    serviceConfig = defaultRestart;
  };
  systemd.services.headscale = {
    after = [ "keycloak.service" ];
    requires = [ "keycloak.service" ];
    startLimitBurst = 10;
    startLimitIntervalSec = 600;
    serviceConfig = defaultRestart;
  };
  systemd.services.tailscaled = {
    after = [ "headscale.service" ];
    requires = [ "headscale.service" ];
    startLimitBurst = 10;
    startLimitIntervalSec = 600;
    serviceConfig = defaultRestart;
  };
  systemd.services.sshd = {
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    startLimitBurst = 10;
    startLimitIntervalSec = 600;
    serviceConfig = defaultRestart;
  };

  # Enable tailscale network
  hosts.tailscale.enable = true;
  # Enable exit-node features
  services.tailscale.useRoutingFeatures = "server";

  hosts.openssh = {
    enable = true;
    allowUsers = [ "*@100.64.0.0/10" ];
    listenAddress = config.hidden.tailscale_hosts.shoryuken;
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://iwa7rtli@iwa7rtli.repo.borgbase.com/./repo";
  };

  nix.settings.trusted-users = [ "martijn" ]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
