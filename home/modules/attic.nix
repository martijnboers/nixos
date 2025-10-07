{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.maatwerk.attic;
in
{
  options.maatwerk.attic = {
    enable = mkEnableOption "Push to bin cache";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ attic-client ];

    systemd.user.services.attic = {
      Unit.Description = "Auto watch store, upload binary cache";
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStart = "${lib.getExe pkgs.attic-client} watch-store default";
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
      };
    };
  };
}
