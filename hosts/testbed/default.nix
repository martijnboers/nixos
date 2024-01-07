{
  lib,
  pkgs,
  ...
}: {
  # QEMU virtual machine
  networking.hostName = "testbed";

  imports = [
    ./modules/caddy.nix
    ./modules/vaultwarden.nix
  ];

  hosts.caddy.enable = true;
  hosts.openssh.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
}
