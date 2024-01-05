{
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "lapdance";

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
}
