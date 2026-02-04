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
    # 1. Enable the Serial Hardware (UART)
    # Corresponds to: "Select Yes to keep the serial port hardware enabled."
    hardware.raspberry-pi.config.all.options = {
      enable_uart = {
        enable = true;
        value = true;
      };
    };

    # 2. Disable the Serial Console (Login Shell)
    # Corresponds to: "When asked about a login shell, select No."
    # The default configuration in the context enables "console=serial0,115200n8".
    # We override kernelParams to remove the serial console, keeping only the screen console (tty1).
    boot.kernelParams = lib.mkForce [ "console=tty1" ];
  };
}
