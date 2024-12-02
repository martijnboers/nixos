{pkgs, ...}: {
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [];

  # Enable profiles
  thuis.kde.enable = false;
  thuis.hyprland.enable = false;
  thuis.personal.enable = false;
  thuis.work.enable = false;
}
