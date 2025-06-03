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

  services.caddy.virtualHosts."mempool.thuis".extraConfig = ''
    import headscale
    handle @internal {
      reverse_proxy http://localhost:${toString config.services.mempool.frontend.port}
    }
  '';

  services.fulcrum = {
    enable = false;
    address = "0.0.0.0";
    dataDir = "/mnt/fulcrum";
  };

  services.mempool = {
    enable = false;
    electrumServer = "fulcurm";
    address = "0.0.0.0";
  };

  services.bitcoind = {
    enable = false;
    dataDir = "/mnt/bitcoin";
    address = "0.0.0.0";
    txindex = true; # for fulcurm+electrs
    tor.enforce = false;
    rpc.threads = lib.mkForce 8;
    extraConfig = ''
      rpcworkqueue=64
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
