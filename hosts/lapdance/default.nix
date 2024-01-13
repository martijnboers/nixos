{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "lapdance";

  hosts.desktop = {
    enable = true;
    wayland = false;
  };

  # Enable secrets + append hosts
  hosts.secrets.hosts = true;

  hosts.syncthing = {
    enable = true;
    ipaddress = "100.64.0.1";
  };

  # Support gpg for git signing
  hosts.gpg.enable = true;

  # Access through headscale
  fileSystems."/mnt/share" = {
    device = "//hadouken.thuis.plebian.nl/public";
    fsType = "cifs";
    options = ["credentials=${config.age.secrets.smb.path},uid=1000,gid=100"];
  };

  # Docker + QEMU
  hosts.virtualization.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
}
