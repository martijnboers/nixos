{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.uefi;
in
{
  options.hosts.uefi = {
    enable = mkEnableOption "Enable systemd boot + fido2 luks";
    crypto = mkOption {
      type = types.bool;
      default = false;
      description = "Enable yubikey unlock";
    };
  };

  config = mkIf cfg.enable {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      initrd = {
        luks.devices = lib.mkIf cfg.crypto {
          root.crypttabExtraOpts = [ "fido2-device=auto" ];
        };
        systemd.enable = true;
      };
    };
  };
}
