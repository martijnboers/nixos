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
        PermitRootLogin = "no";
        X11Forwarding = false;
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        UseDns = false;

        # Use key exchange algorithms recommended by `nixpkgs#ssh-audit`
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "sntrup761x25519-sha512@openssh.com"
        ];
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
