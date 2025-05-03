{ ... }:
{
  # You leave your car running 24/7 to solve sudoku puzzles you can trade for illegal drugs

  # Automatically generate all secrets required by services.
  # The secrets are stored in /etc/nix-bitcoin-secrets
  nix-bitcoin.generateSecrets = true;

  services.clightning = {
    enable = true;
    address = "0.0.0.0";
  };
  services.electrs.enable = true;
  services.mempool.enable = true;

  services.bitcoind = {
    enable = true;
    dataDir = "/mnt/bitcoin";
    address = "0.0.0.0";
  };

  services.borgbackup.jobs.default.paths = [ "/etc/nix-bitcoin-secrets" ];

  # When using nix-bitcoin as part of a larger NixOS configuration, set the following to enable
  # interactive access to nix-bitcoin features (like bitcoin-cli) for your system's main user
  nix-bitcoin.operator = {
    enable = true;
    name = "martijn";
  };
}
