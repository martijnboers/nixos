{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "glassdoor";
  hosts.desktop = {
    enable = true;
    wayland = true;
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://nads486h@nads486h.repo.borgbase.com/./repo";
    paths = ["/home/martijn"];
    exclude = [
      ".cache"
      "*/cache2" # firefox
      "*/Cache"
      ".config/Slack/logs"
      ".config/Code/CachedData"
      ".container-diff"
      ".npm/_cacache"
      "*/node_modules"
      "*/_build"
      "*/venv"
      "*/.venv"
      "/home/*/.local"
      "/home/*/Downloads"
      "/home/*/Data"
    ];
  };

  hosts.syncthing = {
    enable = true;
    ipaddress = "100.64.0.4";
  };

  services.xserver.videoDrivers = ["amdgpu"];

  # For mount.cifs, required unless domain name resolution is not needed.
  fileSystems."/mnt/share" = {
    device = "//hadouken.plebian.local/public";
    fsType = "cifs";
    options = ["credentials=${config.age.secrets.smb.path},uid=1000,gid=100"];
  };

  # Enable secrets + append hosts
  hosts.secrets.hosts = true;

  # Support gpg for git signing
  hosts.gpg.enable = true;

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

  # Access QMK without sudo
  hardware.keyboard.qmk.enable = true;

  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714; # Kde connect
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714; # Kde connect
        to = 1764;
      }
    ];
  };
}
