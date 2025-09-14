{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.crowdsec;
in
{
  options.hosts.crowdsec = {
    enable = mkEnableOption "Crowdsec services on this host";
  };

  config = mkIf cfg.enable {
    # todo
  };
}
