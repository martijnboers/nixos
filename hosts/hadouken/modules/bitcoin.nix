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
      port = 8333;
      dataDir = "/mnt/garage/misc/bitcoind";
      extraConfig = ''
        rpcallowip=100.64.0.0/10
      '';
      rpc = {
        port = 8332;
        users.martijn = {
          name = "martijn";
          passwordHMAC = "3fa71fb5028a53eb50bbb498e9d25cef$4add8cebef22befac8da95350b4cc9cb388334e73dbc75f28b8e4f3b72b91161";
        };
      };
    };
    age.secrets.bitcoinrpc.file = ../../../secrets/bitcoinrpc.age;
    systemd.services."bitcoind-exporter" = {
      enable = true;
      description = "Export crunching of bitcoind";
      wantedBy = [ "multi-user.target" ];
      environment = {
        BITCOIN_RPC_HOST = "hadouken.machine.thuis";
        BITCOIN_RPC_USER = "martijn";
      };
      serviceConfig = {
        ExecStart = getExe pkgs.prometheus-bitcoin-exporter;
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        EnvironmentFile = config.age.secrets.bitcoinrpc.path;
      };
    };
    networking.firewall = {
      allowedTCPPorts = [ config.services.bitcoind.default.port ];
    };
  };
}
