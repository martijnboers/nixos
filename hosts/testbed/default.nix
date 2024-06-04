{
  lib,
  pkgs,
  ...
}: {
  # QEMU virtual machine
  networking.hostName = "testbed";

  hosts.hyprland.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
}
