{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../home
  ];

  # https://discourse.nixos.org/t/error-gdbus-error-org-freedesktop-dbus-error-serviceunknown-the-name-ca-desrt-dconf-was-not-provided-by-any-service-files/29111
  gtk.enable = lib.mkForce false;
  qt.enable = lib.mkForce false;

  # Enable profiles
  thuis.desktop.enable = false;
  thuis.personal.enable = false;
  thuis.work.enable = false;

  home.packages = with pkgs; [];
}
