{
  config,
  ...
}:
{
  networking.hostName = "rekkaken";

  imports = [
    ./modules/headscale.nix
    ./modules/notifs.nix
    ./modules/uptime.nix
    ./modules/caddy.nix
  ];

  hosts.headscale.enable = true;
  hosts.notifications.enable = true;
  hosts.caddy.enable = true;
  hosts.uptime-kuma.enable = true;
  hosts.prometheus.enable = true;
  hosts.tailscale.enable = true;

  hosts.derper = {
    enable = true;
    domain = "derp2.boers.email";
  };

  age.secrets = {
    rekkaken-exit = {
      file = ../../secrets/rekkaken-exit.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
    # crowdsecgapi = {
    #   file = ../../secrets/crowdsecgapi.age;
    #   owner = "crowdsec";
    #   mode = "0400";
    # };
  };

  # Shared fail2ban services
  hosts.crowdsec = {
    enable = true;
  };

  hosts.exit-node = {
    enable = true;
    floatingIp = config.hidden.wan_ips.floating;
    privateKeyFile = config.age.secrets.rekkaken-exit.path;
    publicInterface = "enp1s0";
  };

  hosts.authdns = {
    enable = true;
    master = true;
  };

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
    ];
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://c4j3xt27@c4j3xt27.repo.borgbase.com/./repo";
  };

  nix.settings.trusted-users = [ "martijn" ]; # allows remote push

  # Server defaults
  hosts.server.enable = true;
}
