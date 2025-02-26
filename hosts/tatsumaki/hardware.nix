{
  lib,
  modulesPath,
  ...
}: {
  # Hardware
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];
  boot.loader.grub.enable = true;
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme"];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  fileSystems."/nix" = {
    device = "/dev/disk/by-partuuid/943c4fbe-01";
    fsType = "ext4";
    neededForBoot = true;
    options = ["noatime"];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 1 * 1024;
    }
  ];

  # Disk config
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };
}
