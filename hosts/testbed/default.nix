{
  lib,
  pkgs,
  ...
}: {
  # QEMU virtual machine
  networking.hostName = "testbed";

  imports = [
    ./modules/caddy.nix
  ];

  programs.caddy.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
}
