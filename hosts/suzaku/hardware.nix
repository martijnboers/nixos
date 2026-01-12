{
  lib,
  config,
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

  boot.loader.systemd-boot.enable = true;

  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
  };

  zramSwap.enable = true;

  systemd.network.networks."10-end0" = {
    matchConfig.Name = "end0";
    networkConfig = {
      DHCP = "no"; # no ipv4 dhcp
      IPv6AcceptRA = true;
    };
    address = [
      "10.10.0.4/24"
    ];
    routes = [
      { Gateway = "10.10.0.1"; }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
