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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
