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
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      settings = {
        default-cache-ttl = 21600;
      };
    };
  };
}
