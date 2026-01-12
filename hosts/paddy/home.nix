{ ... }:
{
  imports = [
    ../../home
  ];

  wayland.windowManager.hyprland.settings.input.kb_options = "caps:escape";
    
  home.packages = [ ];
  maatwerk.hyprland.enable = true;
}
