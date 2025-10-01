{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.openbao;
in
{
  options.hosts.openbao = {
    enable = mkEnableOption "openbao";
  };

  config = mkIf cfg.enable {
    # age.secrets = {
    #   wireguard-server = {
    #     file = ../../../secrets/wireguard-server.age;
    #     owner = "root";
    #     group = "root";
    #     mode = "0400";
    #   };
    # };

    services.caddy.virtualHosts."openbao.thuis".extraConfig = ''
      import headscale
      handle @internal {
        reverse_proxy http://${toString config.services.openbao.settings.listener.default.address}
      }
      respond 403
    '';

    services.borgbackup.jobs.default.paths = [ "/var/lib/openbao" ];

    services.openbao = {
      enable = true;
      settings = {
        ui = true;
        listener.default = {
          type = "tcp";
          tls_disable = true;
          address = "127.0.0.1:8200";
        };
        storage.raft.path = "/var/lib/openbao";
        cluster_addr = "http://127.0.0.1:8201";
        api_addr = "https://openbao.thuis";
      };
    };
  };
}
