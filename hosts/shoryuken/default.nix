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
    ./modules/headscale.nix
    ./modules/keycloak.nix
    ./modules/caddy.nix
    ./modules/n8n.nix
  ];

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

  hosts.openssh = {
    enable = true;
    allowUsers = ["*@100.64.0.0/10" "*@143.178.137.170"];
  };

  # Needed for exit node headscale
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
}
