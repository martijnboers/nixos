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
}
