{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.yubikey;
in
{
  options.hosts.yubikey = {
    enable = mkEnableOption "Yubikey+PGP";
    autolock = mkOption {
      type = types.bool;
      default = false;
      description = "Automatically lock sessions when Yubikey is removed";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yubioath-flutter # 2fa
      yubikey-manager # ykman
    ];

    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };

    environment.etc."pkcs11/modules/yubico.module".text = ''
      module: ${pkgs.yubico-piv-tool}/lib/libykcs11.so
      managed: yes
    '';

    services.udev = mkIf cfg.autolock {
      packages = [ pkgs.yubikey-personalization ];
      extraRules = ''
        ACTION=="remove",\
         ENV{ID_BUS}=="usb",\
         ENV{ID_VENDOR_ID}=="1050",\
         ENV{ID_VENDOR}=="Yubico",\
         RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
      '';
    };

    programs.yubikey-touch-detector.enable = true;
    services.pcscd.enable = true; # gpg daemon
  };
}
