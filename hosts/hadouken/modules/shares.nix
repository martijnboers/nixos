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
    fileSystems."/export/music" = {
      device = "/mnt/zwembad/music";
      options = [ "bind" ];
    };

    fileSystems."/export/bitcoin" = {
      device = "/mnt/garage/misc/bitcoind";
      options = [ "bind" ];
    };

    fileSystems."/export/share" = {
      device = "/mnt/zwembad/share";
      options = [ "bind" ];
    };

    services.nfs.server = {
      enable = true;
      hostName = "hadouken.machine.thuis";
      exports = ''
        /export          100.64.0.0/10(rw,fsid=0,no_subtree_check) 
        /export/music    100.64.0.0/10(rw,nohide,insecure,no_subtree_check)
        /export/bitcoin  100.64.0.0/10(rw,nohide,insecure,no_subtree_check)
        /export/share    100.64.0.0/10(rw,nohide,insecure,no_subtree_check)
      '';
    };
  };
}
