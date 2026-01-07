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

  boot = {
    kernelModules = [ "kvm-intel" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sr_mod"
        "sdhci_pci"
      ];
      systemd.enable = true;
    };
  };

  systemd.network.networks =
    let
      defaultNetwork =
        { adapter, ip }:
        {
          "10-${adapter}" = {
            matchConfig.Name = adapter;
            networkConfig = {
              DHCP = "no";
              IPv6AcceptRA = true;
            };
            address = [
              "10.10.0.${ip}/24"
            ];
            routes = [
              { Gateway = "10.10.0.1"; }
            ];
            linkConfig.RequiredForOnline = "routable";
          };
        };
    in
    lib.attrsets.mergeAttrsList (
      map defaultNetwork [
        {
          adapter = "enp2s0";
          ip = "2";
        }
        {
          adapter = "enp3s0";
          ip = "3";
        }
      ]
    );

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1e1c9093-f746-4f2e-adc7-9c3a5d990024";
    fsType = "ext4";
  };

  fileSystems."/mnt/crypto" = {
    device = "/dev/disk/by-partuuid/75dd214a-61d2-4af7-9c23-1d441d8f7d47";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/108E-DD09";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/a310c3dc-fcab-4f46-a123-ba866980f35d"; }
  ];

  zramSwap.enable = true; # needed for fulcrum
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
