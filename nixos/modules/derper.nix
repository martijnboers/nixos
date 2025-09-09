{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.derper;
in
{
  options.hosts.derper = {
    enable = mkEnableOption "Tailscale derper endpoint";
    domain = mkOption {
      type = types.str;
      description = "Derper domain";
    };
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts.${cfg.domain}.extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString config.services.tailscale.derper.port}
    '';
    services.tailscale.derper = {
      enable = true;
      domain = cfg.domain;
      configureNginx = false;
      openFirewall = true;
      verifyClients = true;
    };
  };
}
