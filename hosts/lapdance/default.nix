{
  config,
  ...
}: {
  networking.hostName = "lapdance";

  hosts.hyprland.enable = true;

  # Enable tailscale network
  hosts.tailscale.enable = true;

  # Support gpg for git signing
  hosts.gpg.enable = true;

  fileSystems."/mnt/music" = {
    device = "//hadouken.thuis.plebian.nl/music";
    fsType = "cifs";
    options = ["credentials=${config.age.secrets.smb.path},uid=1000,gid=100"];
  };
  fileSystems."/mnt/misc" = {
    device = "//hadouken.thuis.plebian.nl/misc";
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
  services.libinput.enable = true;
}
