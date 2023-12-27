{
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "rihanna";

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
}
