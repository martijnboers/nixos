{
  lib,
  pkgs,
  config,
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

  # Access through headscale
  fileSystems."/mnt/share" = {
    device = "//hadouken.thuis.plebian.nl/public";
    fsType = "cifs";
    options = ["credentials=${config.age.secrets.smb.path},uid=1000,gid=100"];
  };

  # Docker + QEMU
  hosts.virtualization.enable = true;

  # Bootloader.
  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Silent Boot
    # https://wiki.archlinux.org/title/Silent_boot
    kernelParams = [
      "quiet"
      "splash"
      "vga=current"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    consoleLogLevel = 0;
    # https://github.com/NixOS/nixpkgs/pull/108294
    initrd = {
      verbose = false;
      kernelModules = ["amdgpu"];
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
}
