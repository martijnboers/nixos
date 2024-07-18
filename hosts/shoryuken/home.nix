{pkgs, ...}: {
  imports = [
    ../../home
  ];

  # Enable profiles
  thuis.desktop.enable = false;
  thuis.personal.enable = false;
  thuis.work.enable = false;
}
