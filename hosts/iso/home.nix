{pkgs, ...}: {
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [];

  # Enable profiles
  maatwerk.kde.enable = false;
  maatwerk.hyprland.enable = false;
  maatwerk.personal.enable = false;
  maatwerk.work.enable = false;
}
