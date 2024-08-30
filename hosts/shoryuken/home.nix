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

  # Doesn't have the space for full vim install
  programs.nixvim.enable = lib.mkForce false;
}
