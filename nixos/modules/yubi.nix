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
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      opensc # PIV driver (/run/current-system/sw/lib/opensc-pkcs11.so)
      yubico-piv-tool # Yubi piv driver (/run/current-system/sw/lib/libykcs11.so)
      yubioath-flutter # 2fa
      yubikey-manager # ykman
    ];

    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };

    # Dual mTLS and PIV GPG support
    environment.etc."opensc/opensc.conf".text = ''
      app default {
        debug = 0; # Set to 0 for daily use to prevent lag
        
        # COEXISTENCE SETTINGS
        connect_exclusive = false;
        disconnect_action = leave;
        transaction_end_action = leave;
        reconnect_action = leave;
        
        # opensc-tool -a
        card_atr 3b:fd:13:00:00:81:31:fe:15:80:73:c0:21:c0:57:59:75:62:69:4b:65:79:40 {
            flags = "keep_alive";
        }
    '';

    environment.sessionVariables = {
      OPENSC_CONF = "/etc/opensc/opensc.conf";
    };

    programs.yubikey-touch-detector.enable = true;

    # for smartcard support
    services = {
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];
    };

  };
}
