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
    ipaddress = mkOption {
      type = types.str;
      description = "Tailscale IP address of the computer";
    };
  };

  config = mkIf cfg.enable {
    services.fail2ban.enable = true;
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
      ports = [666];
      listenAddresses = [
        {
          addr = cfg.ipaddress;
        }
      ];
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
