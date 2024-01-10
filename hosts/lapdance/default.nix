{
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "lapdance";

  hosts.desktop = {
    enable = true;
    wayland = true;
  };

  # Enable secrets + append hosts
  hosts.secrets.hosts = true;

  # Support gpg for git signing
  hosts.gpg.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
}
