{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      systemd.enable = true;
    };
  };

  hardware.graphics = {
    enable = true;
    # Hardware decoding hail-mary packages
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
      libvdpau-va-gl
      vaapiIntel
      vaapiVdpau
      vpl-gpu-rt
    ];
  };

  systemd.network.networks."10-enp114s0" = {
    matchConfig.Name = "enp114s0";
    networkConfig = {
      DHCP = "no"; # no ipv4 dhcp
      IPv6AcceptRA = true;
    };
    address = [
      "10.30.0.2/24"
    ];
    routes = [
      { Gateway = "10.30.0.1"; }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/208e3222-bbd0-4867-9245-4aa9ccb27b45";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8FD7-2AF9";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/416601b3-23c4-4169-9d99-37bae9898e66"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
