{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.thuis.stylix;
in {
  options.thuis.stylix = {
    enable = mkEnableOption "Automatic styling";
  };
  config = mkIf cfg.enable {
    # file:///home/martijn/.config/stylix/palette.html
    stylix = {
      enable = true;
      image = ../assets/img/wp_2.jpg;
      polarity = "dark";
      cursor = {
        package = pkgs.phinger-cursors;
        name = "phinger-cursors-light";
        size = 26;
      };
      base16Scheme = "${pkgs.base16-schemes}/share/themes/material-darker.yaml";
      fonts = {
        serif = {
          package = pkgs.roboto;
          name = "Roboto";
        };
        sansSerif = {
          package = pkgs.roboto;
          name = "Roboto";
        };
        monospace = {
          package = pkgs.jetbrains-mono;
          name = "Jetbrains Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
      targets.nixvim.enable = false;
      targets.hyprland.enable = true;
      targets.hyprlock.enable = false;
    };
  };
}
