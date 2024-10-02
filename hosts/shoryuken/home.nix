{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../home
  ];

  # Enable profiles
  thuis.desktop.enable = false;
  thuis.personal.enable = false;
  thuis.work.enable = false;

  # Scrape off as much possible because of storage restraints
  stylix.enable = lib.mkForce false;
  programs.nixvim.enable = lib.mkForce false;
  programs.nix-index.enable = lib.mkForce false;
  programs.nix-index-database.comma.enable = lib.mkForce false;

  # https://discourse.nixos.org/t/error-gdbus-error-org-freedesktop-dbus-error-serviceunknown-the-name-ca-desrt-dconf-was-not-provided-by-any-service-files/29111
  gtk.enable = lib.mkForce false;
  qt.enable = lib.mkForce false;

  # use 'normal' zsh shell
  thuis.zsh.enable = lib.mkForce false;
  programs.zsh.enable = true;
}
