{
  pkgs,
  config,
  ...
}: let
  defaultRestart = {
    RestartSec = 10;
  };
in {
  networking.hostName = "shoryuken";

  imports = [
    ./modules/notifications.nix
    ./modules/uptime-kuma.nix
    ./modules/headscale.nix
    ./modules/keycloak.nix
    ./modules/caddy.nix
    ./modules/n8n.nix
  ];

  hosts.notifications.enable = true;
  hosts.uptime-kuma.enable = true;
  hosts.headscale.enable = true;
  hosts.keycloak.enable = true;
  hosts.caddy.enable = true;
  hosts.n8n.enable = true;

  # Right order of headscale operations for startup
  systemd.services.headscale = {
    after = ["keycloak.service"];
    requires = ["keycloak.service"];
    startLimitBurst = 10;
    startLimitIntervalSec = 600;
    serviceConfig = defaultRestart;
  };
  systemd.services.tailscaled = {
    after = ["headscale.service"];
    requires = ["headscale.service"];
    startLimitBurst = 10;
    startLimitIntervalSec = 600;
    serviceConfig = defaultRestart;
  };

  # https://discourse.nixos.org/t/error-gdbus-error-org-freedesktop-dbus-error-serviceunknown-the-name-ca-desrt-dconf-was-not-provided-by-any-service-files/29111
  programs.dconf.enable = true;

  # Enable tailscale network
  hosts.tailscale.enable = true;

  hosts.openssh = {
    enable = true;
    allowUsers = ["*@100.64.0.0/10"];
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://iwa7rtli@iwa7rtli.repo.borgbase.com/./repo";
  };

  # Needed for exit node headscale
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  zramSwap.enable = true;
}
