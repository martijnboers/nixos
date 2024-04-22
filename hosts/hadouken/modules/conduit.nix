{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.conduit;
in {
  options.hosts.conduit = {
    enable = mkEnableOption "Matrix chat federation";
  };

  config = mkIf cfg.enable {
    services.caddy.extraConfig = ''
           id.plebian.nl, id.plebian.nl:8448 {
      reverse_proxy /_matrix/* http://localhost:${toString config.services.matrix-conduit.settings.global.port}
           }
    '';

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
