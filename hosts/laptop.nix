{
  lib,
  pkgs,
  ...
}: {
  # TODO
  networking.hostName = "laptop";

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
}
