{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.openssh;
in {
  options.hosts.openssh = {
    enable = mkEnableOption "Enable OpenSSH server";
  };

  config = mkIf cfg.enable {
    services.fail2ban.enable = true;
    services.openssh = {
      enable = true;
      ports = [666];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        ListenAddress = "100.64.0.2";
        AllowUsers = ["100.64.0.0/10"];
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
