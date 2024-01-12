{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.smb;
in {
  options.hosts.smb = {
    enable = mkEnableOption "Enable Samba";
  };

  config = mkIf cfg.enable {
    services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
    networking.firewall.allowedTCPPorts = [
      5357 # wsdd
    ];
    networking.firewall.allowedUDPPorts = [
      3702 # wsdd
    ];

    networking.firewall.allowPing = true;
    services.samba.openFirewall = true;

    services.samba = {
      enable = true;
      securityType = "user";
      extraConfig = ''
        workgroup = WORKGROUP
        server string = smbnix
        netbios name = smbnix
        security = user
        hosts allow = *
        guest account = nobody
        map to guest = bad user
      '';
      shares = {
        public = {
          path = "/mnt/garage";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "martijn";
          "force group" = "users";
        };
      };
    };
  };
}
