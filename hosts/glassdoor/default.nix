{
  lib,
  pkgs,
  ...
}: {
  # Glassdoor machine specific stuff
  networking.hostName = "glassdoor";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  services.xserver.videoDrivers = ["amdgpu"];

  # For mount.cifs, required unless domain name resolution is not needed.
  fileSystems."/mnt/share" = {
    device = "//192.168.1.242/sambashare";
    fsType = "cifs";
    options = ["credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };

  # QEMU virtualization
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
  users.users.martijn.extraGroups = [ "libvirtd" ];
  programs.virt-manager.enable = true;

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

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
  };
}
