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

    fileSystems."/export/share" = {
      device = "/mnt/zwembad/share";
      options = [ "bind" ];
    };

    fileSystems."/export/notes" = {
      device = "/mnt/zwembad/app/notes";
      options = [ "bind" ];
    };

    networking.firewall = {
      allowedTCPPorts = [
        111
        2049
        20048
      ];
    };

    boot.supportedFilesystems = [ "nfs" ];

    services.nfs.server = {
      enable = true;
      exports = ''
        /export          100.64.0.0/10(rw,fsid=0,no_subtree_check) 
        /export/music    100.64.0.0/10(rw,nohide,insecure,no_subtree_check)
        /export/share    100.64.0.0/10(rw,nohide,insecure,no_subtree_check)
        /export/notes  	 100.64.0.0/24(rw,nohide,insecure,no_subtree_check)
      '';
    };
  };
}
