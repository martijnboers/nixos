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

    age.secrets.u2fkeys.file = ../../secrets/u2fkeys.age;

    services.credentialsd = {
      enable = true;
      ui.enable = true;
    };

    security.pam = {
      u2f.settings = {
        authfile = config.age.secrets.u2fkeys.path;
        origin = "pam://nixos";
        pinverification = true;
        userverification = "preferred";
      };
      services = {
        sudo = {
          u2fAuth = true;
          unixAuth = false;
        };
        polkit-1 = {
          u2fAuth = true;
          unixAuth = false; 
        };
      };
    };

    environment.etc."pkcs11/modules/yubico.module".text = ''
      module: ${pkgs.yubico-piv-tool}/lib/libykcs11.so
      managed: yes
    '';

    services.pcscd.enable = true; # gpg daemon
    programs.yubikey-touch-detector.enable = true;

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
  };
}
