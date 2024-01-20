{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "suydersee";

  hosts.syncthing = {
    enable = true;
    ipaddress = "100.64.0.5";
  };

  services.syncthing.settings.folders = {
    "Music" = {
      path = "/mnt/garage/Music";
      devices = ["hadouken" "suydersee"];
    };
  };

  # don't autologin
  services.xserver.displayManager.autoLogin.enable = false;

  hosts.openssh.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
}
