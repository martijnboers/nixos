{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.gpg;
in {
  options.hosts.gpg = {
    enable = mkEnableOption "Enable GPG agent";
  };

  config = mkIf cfg.enable {
    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      settings = {
        default-cache-ttl = 43200;
      };
    };
  };
}
