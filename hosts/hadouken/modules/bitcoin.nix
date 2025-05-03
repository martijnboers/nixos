{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.bitcoin;
in
{
  options.hosts.bitcoin = {
    enable = mkEnableOption "You leave your car running 24/7 to solve sudoku puzzles you can trade for illegal drugs";
  };

  config = mkIf cfg.enable {
    services.bitcoind.default = {
      enable = true;
      dataDir = "/mnt/garage/misc/bitcoind";
      port = 8333;
      extraConfig = ''
        rpcallowip=100.64.0.0/10
      '';
      extraCmdlineOptions = [ "-rpcbind=0.0.0.0 -server=1 -txindex=0" ];
      rpc = {
        users.martijn = {
          name = "martijn";
          passwordHMAC = "3fa71fb5028a53eb50bbb498e9d25cef$4add8cebef22befac8da95350b4cc9cb388334e73dbc75f28b8e4f3b72b91161";
        };
      };
    };

    age.secrets.bitcoinrpc.file = ../../../secrets/bitcoinrpc.age;

    systemd.services = {
      "electrs" = {
        enable = false;
        description = "Electrum server";
        wantedBy = [ "multi-user.target" ];
        environment = {
          ELECTRS_ELECTRUM_RPC_ADDR = "hadouken.machine.thuis:8332";
        };
        serviceConfig = {
          ExecStart = "${getExe pkgs.electrs} --log-filters INFO --db";
          Restart = "on-failure";
          RestartSec = 5;
          EnvironmentFile = config.age.secrets.bitcoinrpc.path;
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ config.services.bitcoind.default.port ];
    };
  };
}
