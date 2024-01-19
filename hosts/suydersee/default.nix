{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "suydersee";

#  hosts.syncthing = {
#    enable = true;
#    ipaddress = "100.64.0.1";
#  };

  # don't autologin
  services.xserver.displayManager.autoLogin.enable = false;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
}
