{
  config,
  lib,
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
    hardware.raspberry-pi.config.all = {
      options = {
        enable_uart = {
          enable = true;
          value = true;
        };
      };
      dt-overlays = {
        disable-bt = {
          enable = true;
          params = { };
        };
        pps-gpio = {
          enable = true;
          params = {
            gpiopin = {
              enable = true;
              value = 4;
            };
          };
        };
      };
    };

    boot.kernelParams = lib.mkForce [ "console=tty1" ];

    services.gpsd = {
      enable = true;
      devices = [ "/dev/ttyAMA0" ];
      readonly = true;
    };

    age.secrets.nts = {
      file = ../../../secrets/nts.age;
      owner = "ntpd-rs";
      group = "ntpd-rs";
    };

    services.ntpd-rs = {
      enable = true;
      useNetworkingTimeServers = false;
      settings = {
        source = lib.mkForce [
          # PPS Source (Precision Time)
          # Directly reads the kernel PPS device for high accuracy.
          {
            mode = "pps";
            path = "/dev/pps0";
            precision = 1.0e-7; # 100ns precision estimate
          }
          # Fallback upstream servers
          {
            mode = "server";
            address = "194.58.206.20";
          }
          {
            mode = "server";
            address = "194.58.204.20";
          }
        ];
        server = [
          {
            listen = "[::]:123";
          }
        ];
        nts-ke-server = [
          {
            listen = "[::]:4460";
            certificate-chain-path = ../../../secrets/keys/nts.crt;
            private-key-path = config.age.secrets.nts.path;
          }
        ];
      };
    };

    systemd.services.ntpd-rs = {
      serviceConfig = {
        SupplementaryGroups = [ "dialout" ];
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "ntpd-rs";
        Group = lib.mkForce "ntpd-rs";
      };
    };

    users.users.ntpd-rs = {
      isSystemUser = true;
      group = "ntpd-rs";
      extraGroups = [ "dialout" ];
    };
    users.groups.ntpd-rs = { };

    # Ensure /dev/pps0 is accessible by the dialout group
    services.udev.extraRules = ''
      SUBSYSTEM=="pps", KERNEL=="pps[0-9]*", OWNER="root", GROUP="dialout", MODE="0660"
    '';
  };
}
