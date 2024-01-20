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

  hosts.openssh.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.nameservers = ["2a00:1098:2c::1" "2a01:4f8:c2c:123f::1"];
}
