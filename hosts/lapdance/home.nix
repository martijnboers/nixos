{...}: {
  imports = [
    ../../home
  ];

  wayland.windowManager.hyprland.settings.monitor = "eDP-1,disable"; # builtin

  # Enable profiles
  thuis.hyprland.enable = true;
  thuis.personal.enable = false;
  thuis.work.enable = true;
}
