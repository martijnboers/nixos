{
  lib,
  pkgs,
  ...
}: {
  # Glassdoor machine specific stuff
  networking.hostName = "glassdoor";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  services.xserver.videoDrivers = ["amdgpu"];
  boot.initrd.kernelModules = ["amdgpu"];

  # For mount.cifs, required unless domain name resolution is not needed.
  fileSystems."/mnt/share" = {
    device = "//192.168.1.242/sambashare";
    fsType = "cifs";
    options = ["credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };

  # virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

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
