{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1dc63794-7ade-4515-bb78-5ad39efc3cec";
    fsType = "ext4";
  };

  boot = {
    kernelModules = [ "kvm-intel" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];

      luks = {
        devices."luks-a5c81d3f-2beb-4f03-846a-8180b66906c2" = {
          device = "/dev/disk/by-uuid/a5c81d3f-2beb-4f03-846a-8180b66906c2";
          crypttabExtraOpts = [ "fido2-device=auto" ];
        };
        devices."luks-75b2ca82-089f-43a6-9898-717ecff82bc1" = {
          device = "/dev/disk/by-uuid/75b2ca82-089f-43a6-9898-717ecff82bc1";
          crypttabExtraOpts = [ "fido2-device=auto" ];
        };
      };
      systemd.enable = true;
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2640-9029";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  systemd.network.networks = {
    "50-dhcp" = {
      matchConfig.Name = "en*";
      networkConfig.DHCP = "yes";
      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
      linkConfig.RequiredForOnline = "no";
    };
    "50-wireless" = {
      matchConfig.Name = "wlan0";
      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
      networkConfig = {
        DHCP = "yes";
        IgnoreCarrierLoss = "3s";
      };
    };
  };

  networking.wireless.iwd = {
    enable = true;
    settings = {
      IPv6.Enabled = true;
      # https://man.archlinux.org/man/iwd.network.5#SETTINGS
      Settings = {
        AutoConnect = true;
        Hidden = true; # show hidden
        AlwaysRandomizeAddress = true; # random mac
      };
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/8e846295-8a8c-4bab-a07a-d615743733e1"; }
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/8e846295-8a8c-4bab-a07a-d615743733e1";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
