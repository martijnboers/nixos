{ ... }:
{
  networking.hostName = "shoryuken";

  imports = [
    ./modules/endlessh.nix
    ./modules/keycloak.nix
    ./modules/uptime.nix
    ./modules/cinny.nix
    ./modules/caddy.nix
    ./modules/pgrok.nix
  ];

  hosts.keycloak.enable = true;
  hosts.uptime-kuma.enable = true;
  hosts.caddy.enable = true;
  hosts.prometheus.enable = true;
  hosts.pgrok.enable = false;
  hosts.cinny-web.enable = false;
  hosts.endlessh.enable = true;

  # one of two
  hosts.authdns.enable = true;

  # Enable tailscale network
  hosts.tailscale.enable = true;

  # Enable exit-node features
  services.tailscale = {
    useRoutingFeatures = "both";
    extraSetFlags = [ "--advertise-exit-node" ];
  };

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
    ];
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://iwa7rtli@iwa7rtli.repo.borgbase.com/./repo";
  };

  services.borgbackup.jobs.default.paths = [ "/var/lib/postgresql" ];

  nix.settings.trusted-users = [ "martijn" ]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
