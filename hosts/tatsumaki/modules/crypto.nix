{ lib, config, ... }:
{
  # You leave your car running 24/7 to solve sudoku puzzles you can trade for illegal drugs

  nix-bitcoin = {
    generateSecrets = true;
    secretsDir = "/etc/nix-bitcoin-secrets-second";
  };

  services.clightning = {
    enable = false;
    address = "0.0.0.0";
  };

  services.caddy.virtualHosts."electrum.thuis".extraConfig = ''
    tls {
      issuer internal { ca tatsumaki }
    }
    @internal {
      remote_ip 100.64.0.0/10
    }
    handle @internal {
      reverse_proxy http://localhost:${toString config.services.electrs.port}
    }
  '';

  services.electrs = {
    enable = true;
    address = "0.0.0.0";
    dataDir = "/mnt/electrs";
  };

  services.mempool = {
    enable = false;
    frontend = {
      address = config.hidden.tailscale_hosts.tatsumaki;
      port = 80;
    };
    address = "0.0.0.0";
  };

  services.bitcoind = {
    enable = true;
    dataDir = "/mnt/bitcoin";
    address = "0.0.0.0";
    systemdTimeout = "360min"; # in fork
    tor.enforce = false;
    rpc.threads = lib.mkForce 6;
    extraConfig = ''
      rpcworkqueue=15
    '';
  };

  networking.firewall.allowedTCPPorts = [ config.services.bitcoind.port ];
  services.borgbackup.jobs.default.paths = [ "/etc/nix-bitcoin-secrets" ];

  # When using nix-bitcoin as part of a larger NixOS configuration, set the following to enable
  # interactive access to nix-bitcoin features (like bitcoin-cli) for your system's main user
  nix-bitcoin.operator = {
    enable = true;
    name = "martijn";
  };
}
