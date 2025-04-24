{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.matrix;
in
{
  options.hosts.matrix = {
    enable = mkEnableOption "Matrix chat federation";
  };

  config = mkIf cfg.enable {
    services.matrix-conduit = {
      enable = true;
      settings.global = {
        server_name = "plebian.nl";
        allow_check_for_updates = false;
        allow_registration = false;
        address = "100.64.0.2";
        port = 5553;
      };
    };
  };
}
