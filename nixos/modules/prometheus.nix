{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.prometheus;
  retentionTime = 30 * 6;
in
{
  options.hosts.prometheus = {
    enable = mkEnableOption "Enable prometheus export";
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = 9001;
      retentionTime = toString retentionTime + "d";
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
      };
    };
  };
}
