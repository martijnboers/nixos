{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.openssh;
in {
  options.hosts.openssh = {
    enable = mkEnableOption "Enable OpenSSH server";
    allowUsers = mkOption {
      type = types.listOf types.str;
      default = ["*@100.64.0.0/10"];
      description = "Set IP restrictions";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [22];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        ListenAddress = "0.0.0.0";
        AllowUsers = cfg.allowUsers;
        LogLevel = "VERBOSE";
      };
      openFirewall = true;
      hostKeys = [
        {
          path = "/home/martijn/.ssh/id_ed25519";
          type = "ed25519";
        }
      ];
    };
  };
}
