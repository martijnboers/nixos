{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usbhid"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD"; 
    fsType = "ext4";
    options = [ "noatime" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
