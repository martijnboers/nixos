{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.gpg;
in
{
  options.hosts.gpg = {
    enable = mkEnableOption "Enable GPG agent";
  };

  config = mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
      settings = {
        default-cache-ttl = 43200;
      };
    };
  };
}
