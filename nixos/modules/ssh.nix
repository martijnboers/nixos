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
    ipaddress = mkOption {
      type = types.str;
      description = "Tailscale IP address of the computer";
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
        ListenAddress = cfg.ipaddress;
        AllowUsers = ["*@100.64.0.0/10"];
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
