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
    device = "/dev/disk/by-uuid/94423d1c-1ff2-41cb-9c23-2d8444015324";
    fsType = "ext4";
  };

  boot = {
    kernelModules = [ "kvm-amd" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      kernelModules = [ "amdgpu" ];
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];

      luks.devices.root = {
        device = "/dev/disk/by-uuid/68b29e46-0399-4b6c-bcaa-c29cdf47330e";
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };

      systemd.enable = true;
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0581-2B71";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.rtl-sdr.enable = true;
}
