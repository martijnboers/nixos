{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  cfg = config.hosts.hyprland;
  imports = [./desktop.nix];

  options.hosts.hyprland = {
    enable = mkEnableOption "The rice is ready";
  };

  config = mkIf cfg.enable {
    hosts.desktop.enable = true;
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # hint electron apps to use wayland
      MOZ_ENABLE_WAYLAND = "1"; # ensure enable wayland for Firefox
      WLR_RENDERER_ALLOW_SOFTWARE = "1"; # enable software rendering for wlroots
      WLR_NO_HARDWARE_CURSORS = "1"; # disable hardware cursors for wlroots
      NIXOS_XDG_OPEN_USE_PORTAL = "1"; # needed to open apps after web login
    };

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };
  };
}