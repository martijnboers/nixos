{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.shares;
in
{
  options.hosts.shares = {
    enable = mkEnableOption "Shares";
  };

  config = mkIf cfg.enable {
    # path = "/mnt/zwembad/music";
    # path = "/mnt/garage/misc/bitcoind";
    # path = "/mnt/zwembad/share";
  };
}
