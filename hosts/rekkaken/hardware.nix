{
  lib,
  modulesPath,
  ...
}:
{
  # Hardware
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.enable = true;
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [ "nvme" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  fileSystems."/nix" = {
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_63552951-part1";
    fsType = "ext4";
    neededForBoot = true;
    options = [ "noatime" ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2 * 1024;
    }
  ];

  # Disk config
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };

  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "8.8.8.8"
    ];
    defaultGateway = "172.31.1.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "91.99.135.6";
            prefixLength = 32;
          }
        ];
        ipv6.addresses = [
          {
            address = "2a01:4f8:c2c:ea51::1";
            prefixLength = 64;
          }
          {
            address = "fe80::9400:4ff:fe61:ccf";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "172.31.1.1";
            prefixLength = 32;
          }
        ];
        ipv6.routes = [
          {
            address = "fe80::1";
            prefixLength = 128;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="96:00:04:61:0c:cf", NAME="eth0"
  '';
}
