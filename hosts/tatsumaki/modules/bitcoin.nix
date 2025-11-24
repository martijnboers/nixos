{ lib, config, ... }:
{
  # You leave your car running 24/7 to solve sudoku puzzles you can trade for illegal drugs

  nix-bitcoin = {
    generateSecrets = true;
    secretsDir = "/etc/nix-bitcoin-secrets-second";
  };

  services.clightning = {
    enable = true;
    address = "0.0.0.0";
  };

  services.caddy.virtualHosts."mempool.thuis".extraConfig = ''
    import headscale
    handle @internal {
      reverse_proxy http://localhost:${toString config.services.mempool.frontend.port}
    }
  '';

  services.fulcrum = {
    enable = true;
    address = "0.0.0.0";
    dataDir = "/mnt/crypto/fulcrum";
  };

  services.mempool = {
    enable = true;
    electrumServer = "fulcrum";
    address = "0.0.0.0";
  };

  services.bitcoind = {
    enable = true;
    dataDir = "/mnt/crypto/bitcoin";
    address = "0.0.0.0";
    txindex = true; # for fulcurm+electrs
    tor.enforce = false;
    rpc.threads = lib.mkForce 4;
    extraConfig = ''
      rpcworkqueue=64
      dbcache=1024
      debug=reindex
      maxmempool=100
    '';
  };

  networking.firewall.allowedTCPPorts = [ config.services.bitcoind.port ];
  services.borgbackup.jobs.default.paths = [ config.nix-bitcoin.secretsDir ];

  # When using nix-bitcoin as part of a larger NixOS configuration, set the following to enable
  # interactive access to nix-bitcoin features (like bitcoin-cli) for your system's main user
  nix-bitcoin.operator = {
    enable = true;
    name = "martijn";
  };
}
