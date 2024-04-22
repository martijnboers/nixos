{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.conduit;
  caddyCfg = ''
    reverse_proxy /_matrix/* http://localhost:${toString config.services.matrix-conduit.settings.global.port}
  '';
in {
  options.hosts.conduit = {
    enable = mkEnableOption "Matrix chat federation";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."id.plebian.nl".extraConfig = caddyCfg;
    services.caddy.virtualHosts."id.plebian.nl:8448".extraConfig = caddyCfg;

    services.matrix-conduit = {
      enable = true;
      settings.global = {
        server_name = "id.plebian.nl";
        allow_check_for_updates = false;
        allow_registration = true;
      };
    };
  };
}
