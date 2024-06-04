{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.thuis.hyprland;
in {
  imports = [./desktop.nix];

  options.thuis.hyprland = {
    enable = mkEnableOption "Rice is healthy";
  };

  config = mkIf cfg.enable {
    hosts.desktop.enable = true;
    wayland.windowManager.hyprland.enable = true;
  };
}
