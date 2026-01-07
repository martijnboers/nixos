{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.ntp;
in
{
  options.hosts.ntp = {
    enable = mkEnableOption "NTP/NTS/ROFLCOPTER";
  };

  config = mkIf cfg.enable {
    # Fixes: The U-Boot Serial Hang (The Countdown). Sets the boot delay to a negative value, forcing U-Boot to boot immediately and disable the keyboard interrupt feature that the GPS data was triggering.
    # sudo fw_setenv bootdelay -2

    # Fixes: The extlinux Menu Hang (The Enter choice:). Tells U-Boot and the extlinux menu to only listen to the USB keyboard for input, ignoring the streaming data from the serial port.
    # sudo fw_setenv stdin usbkbd

    # Fixes: The Hard Crash. Tells U-Boot to use the HDMI console for output, preventing it from trying to initialize the serial port for output, which was causing a hard crash when the GPS was transmitting.
    # sudo fw_setenv stdout vidconsole

    # Sets the error output to the HDMI console, for the same reason as above.
    # sudo fw_setenv stderr vidconsole

    boot = {
      kernelPackages = pkgs.linuxPackages_rpi4;
      kernelParams = [ "console=tty1" ];
      blacklistedKernelModules = [
        "hci_uart" # The main driver that hijacks the serial port
        "btsdio" # Bluetooth SDIO driver
        "btbcm" # Broadcom specific Bluetooth helper
        "bluetooth" # The core bluetooth stack itself
      ];
      loader = {
        timeout = 0;
        generic-extlinux-compatible.enable = true;
      };
    };

    hardware = {
      bluetooth.enable = lib.mkForce false;
      raspberry-pi."4" = {
        bluetooth.enable = false;
        audio.enable = false;
      };
    };
  };
}
