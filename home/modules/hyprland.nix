{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hosts.hyprland;
in {
  imports = [./desktop.nix];

  options.hosts.hyprland = {
    enable = mkEnableOption "Rice is healthy";
  };

  config = mkIf cfg.enable {
    hosts.desktop.enable = true;
    wayland.windowManager.hyprland.enable = true;
  };
}
