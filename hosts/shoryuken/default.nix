{ config, ... }:
{
  networking.hostName = "shoryuken";

  imports = [
    ./modules/endlessh.nix
    ./modules/caddy.nix
    ./modules/oidc.nix
    ./modules/acme.nix
  ];

  hosts.oidc.enable = true;
  hosts.caddy.enable = true;
  hosts.acme.enable = true;
  hosts.prometheus.enable = true;
  hosts.endlessh.enable = true;
  hosts.authdns.enable = true;

  hosts.derper = {
    enable = true;
    domain = "derp1.boers.email";
  };

  age.secrets = {
    shoyruken-crowdsec = {
      file = ../../secrets/shoryuken-crowdsec.age;
      owner = "root";
      mode = "0400";
    };
  };

  hosts.crowdsec = {
    enable = true;
    machinePasswordFile = config.age.secrets.shoryuken-crowdsec.path;
  };

  # Enable tailscale network
  hosts.tailscale.enable = true;

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
